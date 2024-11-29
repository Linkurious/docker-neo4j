#!/bin/bash

set -o pipefail
set -e
set -u
set -x

##########
# Functions
##########

##########
# Main
##########
path='/tmp'
neo4j_pod=$(kubectl get pods -n neo4j-preprod --no-headers -o custom-columns=':metadata.name' | fzf)
database=$(kubectl exec -it -n neo4j-preprod "$neo4j_pod" -c "neo4j" -- sh -c 'neo4j-admin database info --format=json' | jq -r '.[].databaseName' | fzf)
echo ${database}
kubectl exec -it -n neo4j-preprod "$neo4j_pod" -c "neo4j" -- sh -c "exec /var/lib/neo4j/bin/neo4j-admin database backup ${database} --to-path=${path} --type=full --verbose"

#we change the name of the backup
kubectl exec -t -n neo4j-preprod "$neo4j_pod" -c "neo4j" -- bash -c "mv ${path}/${database}*.backup ${path}/${database}.backup"
#we copy it to local
kubectl cp --retries=-1 "neo4j-preprod/${neo4j_pod}:${path}/${database}.backup" "/tmp/${database}.backup"
#we check local file
ls -lah "/tmp/$database.backup"
