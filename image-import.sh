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
snapshotname="server1-202104111210"
snapshotos="windows-2016-amd64"

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
# step 1 - rename latest image (if it exists to servername+imagecreate date)
# step 2 - import new image into library as servername-latest
# get json of current private images from cli
imagejson=$(ibmcloud is images --json| jq -r '.[] | select(.visibility == "private")')
# Get the current Image id and created_at for new name $(date -d $created +%Y%m%d%H%M)
imagename="$servername-latest"
imageid=$(echo $imagejson | jq -r --arg imagename $imagename '. | select(.name == $imagename)' | jq -r '.id')
if [ -z "$imageid" ]; then
  logger -p info -t image-$servername "First import of this servers snapshot."
  echo "First import of this servers snapshot."
else
  # rename latest image to severname-created at
  logger -p info -t image-$servername "Image ($imageid) already exists named $imagename, renaming to image-created-date."
  echo "Image ($imageid) already exists named $imagename, renaming."
  createdat=$(echo $imagejson | jq -r --arg imagename $imagename '. | select(.name == $imagename)' | jq -r '.created_at')
  newname=$servername-$(date -d $createdat +%Y%m%d%H%M)
  ibmcloud is image-update $imageid --name $newname -q
  if [ $? -eq 0 ]; then
    logger -p info -t image-$servername "Image rename $servername-latest to $newname successfull."
    echo "Image rename $servername-latest to $newname successfull."
  else
    logger -p info -t image-$servername "Image rename $servername-latest to $newname failed."
    echo "Image rename $servername-latest to $newname failed."
  fi
fi

# import snapshot as server-latest
echo "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
logger -p info -t image-$servername "Importing $snapshotname of os-type $snapshotos into Image Library in $recovery_region."
ibmcloud is image-create $servername-latest --file cos://us-south/encrypted-images/$snapshotname.qcow2 -os-name $snapshotos -q
if [ $? -eq 0 ]; then
  logger -p info -t image-$servername "Image Import of Snapshot ($snapshotname) complete."
  echo "Image Import of Snapshot ($snapshotname) complete."
else
  logger -p info -t image-$servername "Image Import of Snapshot ($snapshotname) failed."
  echo "Image Import of Snapshot ($snapshotname) failed."
fi