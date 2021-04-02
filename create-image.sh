#!/usr/bin/env bash
# Script assumes setup-image-server.sh has installed all pre-reqs
# Script assumes /mnt/image-working is mounted and suitably large enough for image capture (ie >100GB)
# Script assumes /mnt/cos is mounted with COS bucket which is accessible by Image Import in destination region. HMAC keys stored in ~/.passwd-s3fs
# Script assume IBM Cloud apikey stored as ~/apikey.json
# command usage:
# create-image.sh server-name source-region destination-region

# Set Variables

export IBMCLOUD_IS_FEATURE_SNAPSHOT=true
export servername=$1
export snapshot_region=$2
export recovery_region=$3


TIMESTAMP=`date +%Y%m%d%H%M`
snapshotname="$servername-$TIMESTAMP"

logger -p info -t image-$servername "Starting Image process for $servername."

# Login and create volume from snapshot and attach to work server
echo "Logging into $snapshot_region."
logger -p info -t image-$servername "Logging into $snapshot_region."
ibmcloud login --apikey @~/apikey.json -r $snapshot_region > /dev/null

# create snapshot
volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
echo "Creating snapshot of $servername boot volume $volumeid."
logger -p info -t image-$servername "Creating snapshot of $servername boot volume $volumeid."
snapshotid=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json |  jq -r '.id')

# poll for snapshot completion
echo "Waiting for snapshot of $servername boot volume $volumeid to complete..."
logger -p info -t image-$servername "Waiting for snapshot of $servername boot volume $volumeid to complete..."
while true; do
  sleep 60
  snapshotstate=$(ibmcloud is snapshot $snapshotid --json |  jq -r '.lifecycle_state')
  if [ $snapshotstate == 'stable' ]; then
            break
  fi
done
echo "Snapshot of $servername boot volume $volumeid completed."
logger -p info -t image-$servername "Snapshot of $servername boot volume $volumeid completed."

# get running virtual servers instance id & operating system of instance
instanceid=$(ls /var/lib/cloud/instances)
snapshotos=$(ibmcloud is snapshot $snapshotid --json | jq -r ".operating_system.name")

# attach volume based on snapshot to local instance
echo "Attaching snapshot $snapshotname ($snapshotid) to this instance $instanceid."
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
qemu-img convert -p -f raw -O qcow2 $dev /mnt/cos/$snapshotname.qcow2
logger -p info -t image-$servername "Converting $dev to $snapshotname.qcow2 complete."



# Login to region where recovery location is and import cos image into library.  VPC service must have access to instance of COS.
echo "Changing region to recovery region $recovery_region"
logger -p info -t image-$servername "Changing region to recovery region $recovery_region"
ibmcloud target -r $recovery_region > /dev/null
echo "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
logger -p info -t image-$servername "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
ibmcloud is image-create $snapshotname --file cos://us-south/encrypted-images/$snapshotname.qcow2 -os-name $snapshotos
echo "Image Import of Snapshot ($snapshotname) Complete."
logger -p info -t image-$servername "Image Import of Snapshot ($snapshotname) Complete."

#Cleanup etach volume and delete (volume set to autodelete on detach)

echo "Detaching temporary volume from this server ($instanceid)."
logger -p info -t image-$servername "Detaching temporary volume from this server. (ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid)"
result=false
while (! result); do
  sleep 60
  result=(ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid -f --output json | jq -r '.[].result')
  logger -p info -t image-$servername "Detach result = $result."
done

logger -p info -t image-$servername "Detaching temporary volume from this server complete ($instanceid $attachmentid)."