#!/usr/bin/env bash
# Script assumed IBMCLOUD CLI is installed and ~/apikey.json exists
# Script identifies server by name, and creates a snapshot.
# Command Usage:
# snapshot server-name readion
# Set Variables
export IBMCLOUD_IS_FEATURE_SNAPSHOT=true
export servername=$1
export region=$2

TIMESTAMP=`date +%Y%m%d%H%M`
snapshotname="$servername-$TIMESTAMP"

echo "Logging into $region."
ibmcloud login --apikey @~/apikey.json -r $region > /dev/null
echo "Searching for $servername."
# find volume id of intended server based on it's servername and then retreive latest snapshotid for it
export instanceid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.id')
export volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
export snapshotid=$(ibmcloud is snapshots --json |  jq -r '.[] | select((.source_volume.id == env.volumeid))' | jq -s -r 'sort_by(.created_at) | reverse | .[0].id')

echo "Creating snapshot of $servername boot volume $volumeid."
snapshotid=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json |  jq -r '.id')
echo "Snapshot $snapshotid created."

