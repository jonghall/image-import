#!/usr/bin/env bash
# Script assumed IBMCLOUD CLI is installed and ~/apikey.json exists
# Script identifies server by name, and creates a snapshot.
# Command Usage:
# snapshot.sh region instance_name
# Set Variables

if [ $# -ne 2 ];
    then
    echo
    echo "snapshot.sh - Create a boot volume snapshot from running instance."
    echo
    echo "USAGE:"
    echo "snapshot.sh REGION_NAME INSTANCE_NAME"
    echo "  REGION_NAME:      Region Instance is located."
    echo "  INSTANCE_NAME:    Name of the instance to create Snapshot from."
    echo
    exit -1
fi

export region=$1
export servername=$2


TIMESTAMP=`date +%Y%m%d%H%M`
snapshotname="$servername-$TIMESTAMP"

echo "Logging into $region."
ibmcloud login --apikey @~/apikey.json -r $region > /dev/null
echo "Getting Instance and Boot Volume Ids for $servername."
# find volume id of intended server based on it's servername and then retreive latest snapshotid for it
export instanceid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.id')
export volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
export snapshotid=$(ibmcloud is snapshots --json |  jq -r '.[] | select((.source_volume.id == env.volumeid))' | jq -s -r 'sort_by(.created_at) | reverse | .[0].id')

echo "Creating snapshot of $servername boot volume $volumeid."
result=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json)

if [ $? -eq 0 ]
then
    id=$(echo $result | jq -r '.id')
    echo "Snapshot request Successful.  Snapshot Id = $id"
else
    echo "Snapshot Request Failed."
fi