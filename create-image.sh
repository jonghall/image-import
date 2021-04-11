#!/usr/bin/env bash
# Script assumes setup-image-server.sh has installed all pre-reqs
# Script assumes /mnt/cos is mounted with COS bucket which is accessible by Image Import in destination region. HMAC keys stored in ~/.passwd-s3fs
# Script assume IBM Cloud apikey stored as ~/apikey.json
# command usage:
# create-image.sh server-name

# Set Variables
set -e
set -o pipefail
export IBMCLOUD_IS_FEATURE_SNAPSHOT=true
export servername=$1
export snapshot_region="au-syd"
export recovery_region="us-south"

TIMESTAMP=`date +%Y%m%d%H%M`
snapshotname="$servername-$TIMESTAMP"

logger -p info -t image-$servername "Starting Image process for $servername."

# Login and create volume from snapshot and attach to work server
echo "Logging into $snapshot_region."
logger -p info -t image-$servername "Logging into $snapshot_region."
ibmcloud login --apikey @~/apikey.json -r $snapshot_region > /dev/null
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Login Complete."
  echo "Login Complete."
else
  logger -p info -t image-$servername "Login failed."
  echo "Login failed."
  exit 1
fi

# create snapshot
volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
echo "Creating snapshot of $servername boot volume $volumeid."
logger -p info -t image-$servername "Creating snapshot of $servername boot volume $volumeid."
snapshotid=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json |  jq -r '.id')

while true; do
  sleep 60
  snapshotstate=$(ibmcloud is snapshot $snapshotid --json |  jq -r '.lifecycle_state')
  if [[ $snapshotstate == 'stable' ]]; then
            break
  fi
done
echo "Snapshot of $servername boot volume $volumeid completed."
logger -p info -t image-$servername "Snapshot of $servername boot volume $volumeid completed."

# get running virtual servers instance id & operating system of instance
instanceid=$(basename $(readlink -f  /var/lib/cloud/instance))
snapshotos=$(ibmcloud is snapshot $snapshotid --json | jq -r ".operating_system.name")

# attach volume based on snapshot to local instance
echo "Attaching snapshot $snapshotname to this instance."
logger -p info -t image-$servername "Attaching snapshot $snapshotname to this instance. ($snapshotname $instanceid --source-snapshot $snapshotid)"
attachmentid=$(ibmcloud is instance-volume-attachment-add $snapshotname $instanceid --source-snapshot $snapshotid --profile general-purpose --auto-delete true --output json | jq -r '.id')

# Wait until attach is complete then get device
while true; do
  sleep 30
  attachdevice=$(ibmcloud is instance-volume-attachment $instanceid $attachmentid --json |  jq -r 'select(.status == "attached")' | jq -r '.device.id')
  if [ ! -z "$attachdevice" ]; then
            break
  fi
  logger -p info -t image-$servername "Waiting for snapshot $snapshotname to attach ($attachmentid) to this instance $instanceid."
done
logger -p info -t image-$servername "Attachment complete for $snapshotname ($instanceid $attachmentid), at deviceid $attachdevice."

# determine device from deviceid
sleep 10
dev=$(readlink -f /dev/disk/by-id/virtio-${attachdevice:0:20})
logger -p info -t image-$servername "Local Block Device for $snapshotname identified as $dev."

while [ ! -e $dev ]; do
      sleep 10
done
logger -p info -t image-$servername "Block Device $dev ready to access for conversion."

#convert block device to qcow2 file on COS
echo "Converting $dev to $snapshotname.qcow2."
logger -p info -t image-$servername "Converting $dev to $snapshotname.qcow2."
qemu-img convert -c -f raw -O qcow2 $dev /mnt/cos/$snapshotname.qcow2

if [ $? -eq 0 ]; then
  logger -p info -t image-conversion-$servername "Converting $dev to $snapshotname.qcow2 complete."
  echo "Converting $dev to $snapshotname.qcow2 complete."
else
  logger -p info -t image-conversion-$servername "Converting $dev to $snapshotname.qcow2 failed."
  echo "Converting $dev to $snapshotname.qcow2 failed."
  exit 1
fi

# Target  region where recovery location is and import cos image into library.  VPC service must have access to instance of COS.
echo "Changing region to recovery region $recovery_region"
logger -p info -t image-$servername "Changing region to recovery region $recovery_region"
ibmcloud target -r $recovery_region > /dev/null
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Change to region $recovery_region succesful."
  echo "Change to region $recovery_region succesful."
else
  logger -p info -t image-$servername "Change to region $recovery_region failed."
  echo "Change to region $recovery_region failed."
  exit -1
fi

# Import Image into Library
echo "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
logger -p info -t image-$servername "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
ibmcloud is image-create $snapshotname --file cos://us-south/encrypted-images/$snapshotname.qcow2 -os-name $snapshotos
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Image Import of Snapshot ($snapshotname) Complete."
  echo "Image Import of Snapshot ($snapshotname) Complete."
else
  logger -p info -t image-$servername "Image Import of Snapshot ($snapshotname) failed."
  echo "Image Import of Snapshot ($snapshotname) failed."
fi

# Target region where snapshot is and import cos image into library.  VPC service must have access to instance of COS.
echo "Changing region back to snapshot region $snapshot_region to clean up."
logger -p info -t image-$servername "Changing region to $snapshot_region to clean up."
ibmcloud target -r $snapshot_region > /dev/null
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Change to region $snapshot_region succesful."
  echo "Change to region $recovery_region succesful."
else
  logger -p info -t image-$servername "Change to region $snapshot_region failed."
  echo "Change to region $recovery_region failed."
  exit -1
fi

# Get volume id to delete as autodelete not working
echo "Getting attached volume id ($instanceid $attachmentid)"
logger -p info -t image-$servername "Getting attached volume id ($instanceid $attachmentid)"
attachvolid=$(ibmcloud is instance-volume-attachment $instanceid $attachmentid --json| jq -r '.volume.id')
echo "Attached volume id = $attachvolid."
logger -p info -t image-$servername "Attached volume id = $attachvolid."

#Detach volume and delete (volume set to autodelete on detach)
echo "Detaching temporary volume from this server."
logger -p info -t image-$servername "Detaching temporary volume from this server. (ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid)"
ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid --force
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Detach issued succesfully."
  echo "Detach issued succesfully."
else
  logger -p info -t image-$servername "Detach failed."
  echo "Detach failed."
  exit 1
fi

# Wait for deteach to complete and Delete volume as auto-delete not working
while true; do
  sleep 60
  attached=$(ibmcloud is volume $attachvolid --json | jq -r '.volume_attachments')
  if [ "${#attached}" -eq 2 ]; then
            break
  fi
  logger -p info -t image-$servername "Waiting for volume $attachvolid to detach from this instance."
  echo "Waiting for volume $attachvolid to detach from this instance."
done

echo "Deleting temporary volume ($attachvolid)."
logger -p info -t image-$servername "Deleting temporary volume $attachvolid."
ibmcloud is volume-delete $attachvolid --force
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Delete of temporary volume succesful. ($attachvolid)."
  echo "Delete of temporary volume succesful. ($attachvolid)."
else
  logger -p info -t image-$servername "Delete of temporary volume failed. ($attachvolid)."
  echo "Delete of temporary volume failed. ($attachvolid)."
fi
