#!/bin/bash

set -o pipefail
set -e
#set -u
set -x

function usage
{
  echo "Usage:"
  echo "  -h help"
  echo "  -u https://nexus..."
  echo "  -n neo4j version semver"
  exit 0
}

function download_dataset
{
  full_dataset_name=$1
  restore_path=$2
  dataset_name=${full_dataset_name%-*}

  echo "Downloading ${full_dataset_name} from ${nexus_url} for neo4j ${dataset_neo4j_version}"

  wget $debug --header "Authorization: Basic ${nexus_token}" "${nexus_url}/repository/datasets/com/linkurious/neo4j/${dataset_neo4j_version}/${dataset_name}/${full_dataset_name}${dataset_extension}" -O "${restore_path}/${full_dataset_name}${dataset_extension}"
}

function print_volumes_state {
  # This data is output because of the way neo4j-admin works.  It writes the restored set to
  # /var/lib/neo4j by default.  This can fail if volumes aren't sized appropriately, so this
  # aids in debugging.
  echo "Volume mounts and sizing"
  df -h
}

function restore_database {
    sleep 1000
    db=$1

    echo ""
    echo "=== RESTORE $db"

    if [ -d "${data_folder_prefix}/data/databases/$db" ] ; then
        echo "You have an existing graph database at ${data_folder_prefix}/data/databases/$db"

        if [ "$FORCE_OVERWRITE" != "true" ] ; then
            echo "And you have not specified FORCE_OVERWRITE=true, so we will not restore because"
            echo "that would overwrite your existing data.   Exiting.".
            return
        fi
    else
        echo "No existing graph database found at ${data_folder_prefix}/data/databases/$db"
    fi

    # Pass the force flag to the restore operation, which will overwrite
    # whatever is there, if and only if FORCE_OVERWRITE=true.
    if [ "$FORCE_OVERWRITE" = true ] ; then
         # Danger: we are destroying previous data on disk.  On purpose.
         # Optional: you can move the database out of the way to preserve the data just in case,
         # but we don't do it this way because for large DBs this will just rapidly fill the disk
         # and cause out of disk errors.
        echo "We will be force-overwriting any data present"
        FORCE_FLAG="--force"
    else
        # Pass no flag in any other setup.
        echo "We will not force-overwrite data if present"
        FORCE_FLAG=""
    fi

    RESTORE_ROOT=${data_folder_prefix}/data/.restore

    echo "Making restore directory"
    mkdir -p "$RESTORE_ROOT"

  download_dataset "$db" "$RESTORE_ROOT"

    if [ $? -ne 0 ] ; then
        echo "Cannot restore $db"
        return
    fi

    echo "Backup size pre-uncompress:"
    du -hs "$RESTORE_ROOT"
    ls -l "$RESTORE_ROOT"

    # Important note!  If you have a backup name that is "foo.tar.gz" or
    # foo.zip, we need to assume that this unarchives to a directory called
    # foo, as neo4j backup sets are directories.  So we'll remove the suffix
    # after unarchiving and use that as the actual backup target.
    #BACKUP_FILENAME="$db-$TIMESTAMP.tar.gz"
    BACKUP_FILENAME="${db}${dataset_extension}"
    RESTORE_FROM=uninitialized
    if [[ $BACKUP_FILENAME =~ \.tar\.gz$ || $BACKUP_FILENAME =~ \.tgz$ || $BACKUP_FILENAME =~ \.${dataset_extension}$ ]] ; then
        echo "Untarring backup file"
        cd "$RESTORE_ROOT" && tar --force-local --overwrite -zxvf "$BACKUP_FILENAME"

        if [ $? -ne 0 ] ; then
            echo "Failed to unarchive target backup set"
            echo "FAILED TO RESTORE $db"
            return
        fi

        # foo-$TIMESTAMP.tar.gz untars/zips to a directory called foo.
        UNTARRED_BACKUP_DIR=$db

        if [ -z "$BACKUP_SET_DIR" ] ; then
            echo "BACKUP_SET_DIR was not specified, so I am assuming this backup set was formatted by my backup utility"
            RESTORE_FROM="$RESTORE_ROOT/$UNTARRED_BACKUP_DIR"
        else
            RESTORE_FROM="$RESTORE_ROOT/$BACKUP_SET_DIR"
        fi
    elif [[ $BACKUP_FILENAME =~ \.zip$ ]] ; then
        echo "Unzipping backupset"
        cd "$RESTORE_ROOT" && unzip -o "$BACKUP_FILENAME"

        if [ $? -ne 0 ]; then
            echo "Failed to unzip target backup set"
            echo "FAILED TO RESTORE $db"
            return
        fi

        # Remove file extension, get to directory name
        UNZIPPED_BACKUP_DIR=${BACKUP_FILENAME%.zip}

        if [ -z "$BACKUP_SET_DIR" ] ; then
            echo "BACKUP_SET_DIR was not specified, so I am assuming this backup set was formatted by my backup utility"
            if [ -d "$RESTORE_ROOT/backups" ] ; then
                RESTORE_FROM="$RESTORE_ROOT/backups/$db"
            else
                RESTORE_FROM="$RESTORE_ROOT${data_folder_prefix}/data/$db"
            fi
        else
            RESTORE_FROM="$RESTORE_ROOT/$BACKUP_SET_DIR"
        fi
    else
        # If user stores backups as uncompressed directories, we would have pulled down the entire directory
        echo "This backup $BACKUP_FILENAME looks uncompressed."
        RESTORE_FROM="$RESTORE_ROOT/$BACKUP_FILENAME"
    fi

    echo "BACKUP_FILENAME=$BACKUP_FILENAME"
    echo "UNTARRED_BACKUP_DIR=$UNTARRED_BACKUP_DIR"
    echo "UNZIPPED_BACKUP_DIR=$UNZIPPED_BACKUP_DIR"
    echo "RESTORE_FROM=$RESTORE_FROM"

    echo "Set to restore from $RESTORE_FROM - size on disk:"
    du -hs "$RESTORE_FROM"

    # Destination docker directories.
    mkdir -p ${data_folder_prefix}/data/databases
    mkdir -p ${data_folder_prefix}/data/transactions

    cd /data && \

    neo4j_restore_params=(restore \
         --from="$RESTORE_FROM" \
         --database="$db" $FORCE_FLAG \
         --to-data-directory ${data_folder_prefix}/data/databases/ \
         --to-data-tx-directory ${data_folder_prefix}/data/transactions/ \
         --move \
         --verbose)
    if [[  "$neo4j_major" == "5" ]]; then
        neo4j_restore_params=(database restore \
            --from-path="$RESTORE_FROM" \
            --to-path-data ${data_folder_prefix}/data/databases/ \
            --to-path-txn ${data_folder_prefix}/data/transactions/ \
            --verbose "$db")
    fi
    echo "Dry-run command"
    echo ${neo4j_restore_params[@]}

    print_volumes_state

    echo "Now restoring"
    neo4j-admin ${neo4j_restore_params[@]}

    RESTORE_EXIT_CODE=$?

    if [ "$RESTORE_EXIT_CODE" -ne 0 ]; then
        echo "Restore process failed; will not continue"
        echo "Failed to restore $db"
        print_volumes_state
        return $RESTORE_EXIT_CODE
    fi

    # Modify permissions/group, because we're running as root.
    chown -R neo4j ${data_folder_prefix}/data/databases
    chown -R neo4j ${data_folder_prefix}/data/transactions
    chgrp -R neo4j ${data_folder_prefix}/data/databases
    chgrp -R neo4j ${data_folder_prefix}/data/transactions

    echo "Final permissions"
    ls -al "${data_folder_prefix}/data/databases/$db"
    ls -al "${data_folder_prefix}/data/transactions/$db"

    echo "Final size"
    du -hs "${data_folder_prefix}/data/databases/$db"
    du -hs "${data_folder_prefix}/data/transactions/$db"

    if [ "$PURGE_ON_COMPLETE" = true ] ; then
        echo "Purging backupset from disk"
        rm -rf "$RESTORE_ROOT"
    fi

    echo "RESTORE OF $db COMPLETE"
    sleep 1000
}

##########
# Main
##########
if [[ -z $DATASETS ]]; then
  echo "getting from neo config"
  DATASETS=$(cat /config/neo4j.conf/DATASETS)
  DATASET_NEO4J_VERSION=$(cat /config/neo4j.conf/DATASET_NEO4J_VERSION)
fi

debug=""
nexus_url="https://nexus3.linkurious.net"
nexus_token="$NEXUS_TOKEN"
dataset_neo4j_version="$DATASET_NEO4J_VERSION"
data_folder_prefix=""
neo4j_version=$(neo4j --version)
neo4j_major=${neo4j_version%%.*}
dataset_extension='.tgz'
if [[  "$neo4j_major" == "5" ]]; then
dataset_extension='.backup'
fi


while getopts "n:p:u:dh" argument
do
  case $argument in
    u) nexus_url=$OPTARG;;
    n) dataset_neo4j_version=$OPTARG;;
    p) data_folder_prefix=$OPTARG;;
    d) debug='-vv';;
    h) usage;;
    *) usage;;
  esac
done

if [[ -z $dataset_neo4j_version ]]; then
  echo "Missing dataset_neo4j_version"
  usage
fi

# Split by comma
IFS=","
read -a datasets <<< "$DATASETS"
for db in "${datasets[@]}"; do
  restore_database "$db"
  print_volumes_state
done
