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

logger -p info-t snapshot "Starting Image process for $servername."

# Login and create volume from snapshot and attach to work server
echo "Logging into $snapshot_region."
logger -p info-t snapshot "Logging into $snapshot_region."
ibmcloud login --apikey @~/apikey.json -r $snapshot_region > /dev/null

# create snapshot
volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
echo "Creating snapshot of $servername boot volume $volumeid."
logger -p info-t snapshot "Creating snapshot of $servername boot volume $volumeid."
snapshotid=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json |  jq -r '.id')

# poll for snapshot completion
echo "Waiting for snapshot of $servername boot volume $volumeid to complete..."
logger -p info-t snapshot "Waiting for snapshot of $servername boot volume $volumeid to complete..."
while true; do
  sleep 60
  snapshotstate=$(ibmcloud is snapshot $snapshotid --json |  jq -r '.lifecycle_state')
  if [ $snapshotstate == 'stable' ]; then
            break
  fi
done
echo "Snapshot of $servername boot volume $volumeid completed."
logger -p info-t snapshot "Snapshot of $servername boot volume $volumeid completed."

# get running virtual servers instance id & operating system of instance
instanceid=$(ls /var/lib/cloud/instances)
snapshotos=$(ibmcloud is snapshot $snapshotid --json | jq -r ".operating_system.name")

# attach volume based on snapshot to local instance
echo "Attaching snapshot $snapshotname ($snapshotid) to this instance $instanceid."
logger -p info-t snapshot "Attaching snapshot $snapshotname ($snapshotid) to this instance $instanceid."
attachmentid=$(ibmcloud is instance-volume-attachment-add $snapshotname $instanceid --source-snapshot $snapshotid --profile general-purpose --auto-delete true --output json | jq -r '.id')

# wait for volume to be available at /dev/vde
counter=0
while [ ! -e /dev/vde ]; do
      sleep 10
      counter=$((counter + 1))
      if [ $counter -ge 50 ]; then
          echo "Volume $volumeid attachment to instance $instanceid failed waiting for device to be active."
          exit
      fi
done
echo "Snapshot $snapshotname ($snapshotid) is ready to capture."
logger -p info-t snapshot "Snapshot $snapshotname ($snapshotid) is ready to capture."

#run dd capturing block volume into RAW image file
echo "Capturing block volume into RAW image file."
logger -p info-t snapshot "Capturing block volume into RAW image file."
dd if=/dev/vde conv=sync,noerror bs=64K of=/mnt/image-working/$snapshotname.img
logger -p info-t snapshot "Capturing block volume into RAW image file complete."

#detach volume and delete (volume set to autodelete)
echo "Detaching temporary volume from this server ($instanceid)."
logger -p info-t snapshot "Detaching temporary volume from this server ($instanceid)."
ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid -f

#convert img file to qcow2
echo "Converting image to $snapshotname.qcow2."
logger -p info-t snapshot "Converting image to $snapshotname.qcow2."
qemu-img convert -p -f raw -O qcow2 /mnt/image-working/$snapshotname.img /mnt/cos/$snapshotname.qcow2
logger -p info-t snapshot "Converting image to $snapshotname.qcow2 complete."

# delete RAW image and detach volume
echo "Deleting temporary RAW image file."
logger -p info-t snapshot "Deleting temporary RAW image file."
rm -f /mnt/image-working/$snapshotname.img

# Login to region where recovery location is and import cos image into library.  VPC service must have access to instance of COS.
echo "Changing region to recovery region $recovery_region"
logger -p info-t snapshot "Changing region to recovery region $recovery_region"
ibmcloud target -r $recovery_region > /dev/null
echo "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
logger -p info-t snapshot "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
ibmcloud is image-create $snapshotname --file cos://us-south/encrypted-images/$snapshotname.qcow2 -os-name $snapshotos
echo "Image Import of Snapshot ($snapshotname) Complete."
logger -p info-t snapshot "Image Import of Snapshot ($snapshotname) Complete."
