#!/usr/bin/env bash
# create-image-background.sh - A script to convert snapshots to custom images
# Author: Jon Hall
# Copyright (c) 2021
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Variables
#set -e
#set -o pipefail
export IBMCLOUD_IS_FEATURE_SNAPSHOT=true
instanceid=$(basename $(readlink -f  /var/lib/cloud/instance))

logger -p info -t image "Starting Image Conversion work queue on instance $instanceid."

export REDIS_CLI="redli -u rediss://$REDISUSER:$REDISPW@$REDISURL --certfile=$REDIS_CERTFILE"
q1="queue"
POPQUEUE="${REDIS_CLI} LPOP $q1"
nil=$(echo -n -e '\r\n')

process() {
  export servername=$1
  TIMESTAMP=`date +%Y%m%d%H%M`
  snapshotname="$servername-$TIMESTAMP"

  logger -p info -t image-process "Starting Image process for $servername."

  # Login and create volume from snapshot and attach to work server
  logger -p info -t image-process "Logging into $snapshot_region."
  ibmcloud login --apikey @~/apikey.json -r $snapshot_region
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Login Complete."
  else
    logger -p error -t image-process "Login failed."
    return
  fi

  # Target region where you will take snapshot.
  logger -p info -t image-process "Changing region to $snapshot_region to take snapshot."
  ibmcloud target -r $snapshot_region > /dev/null
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Change to region $snapshot_region successful."
  else
    logger -p error -t image-process "Change to region $snapshot_region failed."
    return
  fi

  # create snapshot
  ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)'
  export volumeid=$(ibmcloud is instances --json | jq -r '.[] | select(.name == env.servername)' | jq -r '.boot_volume_attachment.volume.id')
  logger -p info -t image-process "Creating snapshot of $servername boot volume $volumeid."
  export snapshotid=$(ibmcloud is snapshot-create --name $snapshotname --volume $volumeid --json |  jq -r '.id')
  if [ -z "${snapshotid}" ]; then
        logger -p error -t image-process "Snapshot failed for $servername volumeid $volumeid. Exiting."
        return
  fi

  while true; do
    sleep 60
    export snapshotstate=$(ibmcloud is snapshot $snapshotid --json |  jq -r '.lifecycle_state')
    if [[ $snapshotstate == 'stable' ]]; then
              break
    fi
  done
  logger -p info -t image-process "Snapshot of $servername boot volume $volumeid completed."

  # get running virtual servers instance id & operating system of instance
  export instanceid=$(basename $(readlink -f  /var/lib/cloud/instance))
  export snapshotos=$(ibmcloud is snapshot $snapshotid --json | jq -r ".operating_system.name")

  # attach volume based on snapshot to local instance
  logger -p info -t image-process "Attaching snapshot $snapshotname to this instance. ($snapshotname $instanceid --source-snapshot $snapshotid)"
  export attachmentid=$(ibmcloud is instance-volume-attachment-add $snapshotname $instanceid --source-snapshot $snapshotid --profile general-purpose --auto-delete true --output json | jq -r '.id')

  # Wait until attach is complete then get device
  while true; do
    sleep 30
    export attachdevice=$(ibmcloud is instance-volume-attachment $instanceid $attachmentid --json |  jq -r 'select(.status == "attached")' | jq -r '.device.id')
    if [ ! -z "$attachdevice" ]; then
              break
    fi
    logger -p info -t image-process "Waiting for snapshot $snapshotname to attach ($attachmentid) to this instance $instanceid."
  done
  logger -p info -t image-process "Attachment complete for $snapshotname ($instanceid $attachmentid), at deviceid $attachdevice."

  # determine device from deviceid
  sleep 30
  export dev=$(readlink -f /dev/disk/by-id/virtio-${attachdevice:0:20})
  logger -p info -t image-process "Local Block Device for $snapshotname identified as $dev."

  while [ ! -e $dev ]; do
        sleep 10
  done
  logger -p info -t image-process "Block Device $dev ready to access for conversion."

  #convert block device to qcow2 file on COS
  logger -p info -t image-process "Converting $dev to $snapshotname.qcow2."
  qemu-img convert -c -f raw -O qcow2 $dev /mnt/cos/$snapshotname.qcow2

  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Conversion of $dev to $snapshotname.qcow2 complete."
  else
    logger -p info -t image-process "Conversion of $dev to $snapshotname.qcow2 failed."
    return
  fi

  # Target  region where recovery location is and import cos image into library.  VPC service must have access to instance of COS.
  logger -p info -t image-process "Changing region to recovery region $recovery_region"
  ibmcloud target -r $recovery_region > /dev/null
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Change to region $recovery_region succesful."
  else
    logger -p info -t image-process "Change to region $recovery_region failed."
    return
  fi

  # Import Image into Library
  # step 1 - rename latest image (if it exists to servername+imagecreate date)
  # step 2 - import new image into library as servername-latest
  # get json of current private images from cli
  export imagejson=$(ibmcloud is images --json| jq -r '.[] | select(.visibility == "private")')
  # Get the current Image id and created_at for new name $(date -d $created +%Y%m%d%H%M)
  export imagename="$servername-latest"
  export imageid=$(echo $imagejson | jq -r --arg imagename $imagename '. | select(.name == $imagename)' | jq -r '.id')
  if [ -z "$imageid" ]; then
    logger -p info -t image-process "First import of this servers snapshot."
  else
    # rename latest image to severname-created at
    logger -p info -t image-process "Image ($imageid) already exists named $imagename, renaming to image-created-date."
    export createdat=$(echo $imagejson | jq -r --arg imagename $imagename '. | select(.name == $imagename)' | jq -r '.created_at')
    export newname=$servername-$(date -d $createdat +%Y%m%d%H%M)
    ibmcloud is image-update $imageid --name $newname -q
    if [ $? -eq 0 ]; then
      logger -p info -t image-process "Image rename $servername-latest to $newname successfull."
    else
      logger -p info -t image-process "Image rename $servername-latest to $newname failed."
    fi
  fi

  # import snapshot as server-latest
  logger -p info -t image-process "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
  ibmcloud is image-create $servername-latest --file $cos_bucket/$snapshotname.qcow2 -os-name $snapshotos -q
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Image Import of Snapshot ($snapshotname) complete."
  else
    logger -p info -t image-process "Image Import of Snapshot ($snapshotname) failed."
  fi

  # Target region where snapshot is and import cos image into library.  VPC service must have access to instance of COS.
  logger -p info -t image-process "Changing region to $snapshot_region to clean up."
  ibmcloud target -r $snapshot_region > /dev/null
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Change to region $snapshot_region successful."

  else
    logger -p info -t image-process "Change to region $snapshot_region failed."
    return
  fi

  # Get volume id to delete as autodelete not working
  logger -p info -t image-process "Getting attached volume id ($instanceid $attachmentid)"
  export attachvolid=$(ibmcloud is instance-volume-attachment $instanceid $attachmentid --json| jq -r '.volume.id')
  logger -p info -t image-process "Attached volume id = $attachvolid."

  #Detach volume and delete (volume set to autodelete on detach)
  logger -p info -t image-process "Detaching temporary volume from this server. (ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid)"
  ibmcloud is instance-volume-attachment-detach $instanceid $attachmentid --force
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Detach issued successfully."
  else
    logger -p info -t image-process "Detach failed."
    return
  fi

  # Wait for deteach to complete and Delete volume as auto-delete not working
  while true; do
    sleep 60
    export attached=$(ibmcloud is volume $attachvolid --json | jq -r '.volume_attachments')
    if [ "${#attached}" -eq 2 ]; then
              break
    fi
    logger -p info -t image-process "Waiting for volume $attachvolid to detach from this instance."
  done

  logger -p info -t image-process "Deleting temporary volume $attachvolid."
  ibmcloud is volume-delete $attachvolid --force
  if [ $? -eq 0 ]; then
    logger -p info -t image-process "Delete of temporary volume successful. ($attachvolid)."
  else
    logger -p info -t image-process "Delete of temporary volume failed. ($attachvolid)."
  fi
}

consume() {
    logger -p info -t image-process "Waiting for Image Conversion jobs."
    while true; do        # move message to processing queue
        MSG=$($POPQUEUE)
        if [[ -z "$MSG" ]]; then
            break
        fi
        # remove message from message queue
        if [ "$MSG" != "nil" ]; then
          logger -p info -t image-process "Received image-conversion request for $MSG"
          process "$MSG"
        fi
        sleep 10;
    done
}

while true; do
  consume
done
