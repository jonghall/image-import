#!/usr/bin/env bash
# Script assumed IBMCLOUD CLI is installed and ~/apikey.json exists
# Script provisions new server from snapshot.
# Command Usage:
# provision.sh servername region vpc zone profile_name subnet snapshot


if [ $# -ne 7 ];
    then
    echo
    echo "provision.sh - provision a new instance from a snapshot."
    echo
    echo "USAGE:"
    echo "provision.sh INSTANCE_NAME VPC_NAME ZONE_NAME SUBNET_NAME PROFILE_NAME SNAPSHOT_NAME"
    echo "  INSTANCE_NAME:  Name of the instance."
    echo "  VPC_NAME:       Name of the VPC."
    echo "  ZONE_NAME:      Name of the zone."
    echo "  PROFILE_NAME:   Name of the profile."
    echo "  SUBNET_NAME:    NAME of the subnet."
    echo
    exit -1
fi

export servername=$1
export region=$2
export vpc=$3
export zone=$4
export subnet=$5
export profile_name=$6
export snapshot=$7

echo "Logging into $region."
ibmcloud login --apikey @~/apikey.json -r $region > /dev/null

# get vpcid from vpc name
export vpcid=$(ibmcloud is vpcs --json | jq -r '.[] | select(.name == env.vpc)' | jq -r '.id')
echo "VPC $vpc ($vpcid) identified."

# get subnetid from subnet name
export subnetid=$(ibmcloud is subnets --json | jq -r '.[] | select(.name == env.subnet)' | jq -r '.id')
echo "Subnet $subnet ($subnetid) identified."

# get snapshotid from snapshot name
export snapshotid=$(ibmcloud is snapshots --json | jq -r '.[] | select(.name == env.snapshot)' | jq -r '.id')
echo "Snapshot $snapshot ($snapshotid) identified."

echo "Provisioning $servername from snapshot $snapshot."

#    IBMCLOUD CLI
#    ibmcloud is instance-create INSTANCE_NAME VPC ZONE_NAME PROFILE_NAME SUBNET --boot-volume BOOT_VOLUME_JSON
#     INSTANCE_NAME: Name of the instance.
#     VPC:           ID of the VPC.
#     ZONE_NAME:     Name of the zone.
#     PROFILE_NAME:  Name of the profile.
#     SUBNET:        ID of the subnet.

result=$(ibmcloud is instance-create $servername $vpcid $zone $profile_name $subnetid --boot-volume "{\"name\": \"boot-vol-attachment-$servername\", \"volume\": {\"name\": \"boot-vol-name-$servername\", \"profile\": {\"name\": \"general-purpose\"}, \"source_snapshot\": {\"id\": \"$snapshotid\"}}}" --json)

if [ $? -eq 0 ]
then
    id=$(echo $result | jq -r '.id')
    echo "Provisioning Request Successful.  Instance Id = $id"
else
    echo "Provisioning Request Failed."
fi

