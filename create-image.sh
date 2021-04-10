#!/usr/bin/env bash
# Script assumes setup-image-server.sh has installed all pre-reqs
# Script assumes /mnt/cos is mounted with COS bucket which is accessible by Image Import in destination region. HMAC keys stored in ~/.passwd-s3fs
# Script assume IBM Cloud apikey stored as ~/apikey.json
# command usage:
# create-image.sh
# run add-server.sh to add servernames to queue.

# Set Variables

export IBMCLOUD_IS_FEATURE_SNAPSHOT=true
instanceid=$(basename $(readlink -f  /var/lib/cloud/instance))

logger -p info -t image-conversion "Starting Image Conversion work queue on instance $instanceid."

export USERNAME="admin"
export REDIS_CLI="redli -u rediss://$USERNAME:$PASSWORD@25a8ac71-9f05-4ddf-9768-e5546ab67dbb.bsbaodss0vb4fikkn2bg.private.databases.appdomain.cloud:30129/0 --certfile=/root/da4adf1d-5570-4714-b526-f6d3e202e02e"
q1="queue"
POPQUEUE="${REDIS_CLI} LPOP $q1"
nil=$(echo -n -e '\r\n')

process() {
  export servername=$1
  export snapshot_region="au-syd"
  export recovery_region="us-south"
  TIMESTAMP=`date +%Y%m%d%H%M`
  snapshotname="$servername-$TIMESTAMP"

  logger -p info -t image-conversion-$servername "Starting Image process for $servername."

  # Login and create volume from snapshot and attach to work server
  logger -p info -t image-conversion-$servername "Logging into $snapshot_region."
  ibmcloud login --apikey @~/apikey.json -r $snapshot_region -q > /dev/null
  if [ $? -eq 0 ]; then
    logger -p info -t image-conversion-$servername "Log into $snapshot_region successful."
  else
    logger -p info -t image-conversion-$servername "Log into $snapshot_region failed."
    return
  fi
  # create snapshot
  volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
  logger -p info -t image-conversion-$servername "Creating snapshot of $servername boot volume $volumeid."
  snapshotid=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json |  jq -r '.id')
  if [ $? -eq 0 ]; then
    logger -p info -t image-conversion-$servername "Snapshot request $snapshotname successful."
  else
    logger -p info -t image-conversion-$servername "Snapshot request $snapshotname failed."
    return
  fi

  # poll for snapshot completion
  logger -p info -t image-conversion-$servername "Waiting for snapshot of $servername boot volume $volumeid to complete..."
  while true; do
    sleep 60
    snapshotstate=$(ibmcloud is snapshot $snapshotid --json |  jq -r '.lifecycle_state')
    if [[ $snapshotstate == "stable" ]]; then
              break
    fi
  done
  logger -p info -t image-conversion-$servername "Snapshot of $servername boot volume $volumeid completed."

  # get running virtual servers instance id & operating system of instance
  snapshotos=$(ibmcloud is snapshot $snapshotid --json | jq -r ".operating_system.name")

  # attach volume based on snapshot to local instance
  logger -p info -t image-conversion-$servername "Attaching snapshot $snapshotname to this instance. ($snapshotname $instanceid --source-snapshot $snapshotid)"
  attachmentid=$(ibmcloud is instance-volume-attachment-add $snapshotname $instanceid --source-snapshot $snapshotid --profile general-purpose --auto-delete true --output json | jq -r '.id')

  # Wait until attach is complete then get device
  while true; do
    sleep 30
    attachdevice=$(ibmcloud is instance-volume-attachment $instanceid $attachmentid --json |  jq -r 'select(.status == "attached")' | jq -r '.device.id')
    if [[ ! -z "$attachdevice" ]]; then
              break
    fi
    logger -p info -t image-conversion-$servername "Waiting for snapshot $snapshotname to attach ($attachmentid) to this instance $instanceid."
  done
  logger -p info -t image-conversion-$servername "Attachment complete for $snapshotname ($instanceid $attachmentid), at deviceid $attachdevice."

  # determine device from deviceid
  sleep 10
  dev=$(readlink -f /dev/disk/by-id/virtio-${attachdevice:0:20})
  logger -p info -t image-conversion-$servername "Local Block Device for $snapshotname identified as $dev."

  while [ ! -e $dev ]; do
        sleep 10
  done
  logger -p info -t image-conversion-$servername "Block Device $dev ready to access for conversion."

  #convert block device to qcow2 file on COS
  logger -p info -t image-conversion-$servername "Converting $dev to $snapshotname.qcow2."
  qemu-img convert -c -f raw -O qcow2 $dev /mnt/cos/$snapshotname.qcow2
  if [ $? -eq 0 ]; then
    logger -p info -t image-conversion-$servername "Converting $dev to $snapshotname.qcow2 complete."
  else
    logger -p info -t image-conversion-$servername "Converting $dev to $snapshotname.qcow2 failed."
    return
  fi

  # Detach volume and delete (volume set to auto delete on detach)
  logger -p info -t image-conversion-$servername "Detaching temporary volume from this server. (ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid)"
  detachresult=false
  while [ ! $detachresult ]; do
    sleep 60
    detachresult=$(ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid --force --output json | jq -r '.[].result')
    logger -p info -t image-conversion-$servername "Detach result = $detachresult."
  done
  logger -p info -t image-conversion-$servername "Detaching temporary volume from this server complete ($instanceid $attachmentid)."

  # Target region where recovery location is and import cos image into library.  VPC service must have access to instance of COS.
  logger -p info -t image-conversion-$servername "Changing region to recovery region $recovery_region"
  ibmcloud target -r $recovery_region > /dev/null
  logger -p info -t image-conversion-$servername "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
  ibmcloud is image-create $snapshotname --file cos://us-south/encrypted-images/$snapshotname.qcow2 -os-name $snapshotos
}

consume() {
    logger -p info -t image-conversion "Waiting for Image Conversion jobs."
    while true; do
        # move message to processing queue
        MSG=$($POPQUEUE)
        if [[ -z "$MSG" ]]; then
            break
        fi
        # remove message from message queue
        if [ "$MSG" != "nil" ]; then
          logger -p info -t image-conversion "Received image-conversion request for $MSG"
          process "$MSG"
        fi
        sleep 10;
    done
}

consume
