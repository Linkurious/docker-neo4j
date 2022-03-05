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

##########
# Main
##########
debug=""
nexus_url="https://nexus3.linkurious.net"
nexus_token="$NEXUS_TOKEN"
neo4j_version="$NEO4J_VERSION"
dataset_name="$DATASET_NAME"
dataset_version="$DATASET_VERSION"

while getopts "n:u:dh" argument
do
  case $argument in
    u) nexus_url=$OPTARG;;
    n) neo4j_version=$OPTARG;;
    d) debug='-vv';;
    h) usage;;
    *) usage;;
  esac
done

if [[ -z $neo4j_version ]]; then
  echo "Missing neo4j_version"
  usage
fi
full_dataset_name="${dataset_name}-${dataset_version}"

echo "Downloading ${full_dataset_name} from ${nexus_url} for neo4j ${neo4j_version}"

curl -L $debug -H "Authorization: Basic ${nexus_token}" "${nexus_url}/repository/datasets/com/linkurious/neo4j/${neo4j_version}/${dataset_name}/${full_dataset_name}.tgz" -o "$full_dataset_name}.tgz"
