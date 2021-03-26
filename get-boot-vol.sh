#!/usr/bin/env bash
# Set Variables
export IBMCLOUD_IS_FEATURE_SNAPSHOT=true
export servername=$2
export region=$1

echo "Logging into $region."
ibmcloud login --apikey @~/apikey.json -r $region > /dev/null
echo "Searching for $servername."
# find volume id of intended server based on it's servername and then retreive latest snapshotid for it
export instanceid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.id')
export volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
export snapshotid=$(ibmcloud is snapshots --json |  jq -r '.[] | select((.source_volume.id == env.volumeid))' | jq -s -r 'sort_by(.created_at) | reverse | .[0].id')
export snapshotos=$(ibmcloud is snapshot $snapshotid --json | jq -r ".operating_system.name")
echo "instanceid=$instanceid"
echo "volumeid=$volumeid"
echo "snapshotid=$snapshotid"
echo "snapshotos=$snapshotos"
