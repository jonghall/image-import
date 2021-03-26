#!/usr/bin/env bash

#install kvm image tool & s3fuse
yum -y install epel-release
yum -y install qemu-img
yum -y install s3fs-fuse
yum -y install jq

# install IBM Cloud CLI tools
curl -sL https://raw.githubusercontent.com/IBM-Cloud/ibm-cloud-developer-tools/master/linux-installer/idt-installer | bash
ibmcloud plugin install vpc-infrastructure

# create two mnt points
mkdir /mnt/cos
mkdir /mnt/image-working

# Partition & format working volume and then mount to /mnt/image-working  assume /dev/vdd

echo -e "n\np\n1\n\n\nt\n8e\n\nw\n" | sudo fdisk /dev/vdd
mkfs.ext4 /dev/vdd
e2label /dev/vdd1 image-working
echo "LABEL=image-working /mnt/image-working  ext4  defaults,nofail  0  2" >> /etc/fstab
mount /dev/vdd /mnt/image-working

# setup and mount COS using s3fuse and mount to /mnt/cos
# replace HMAC keys for COS service with actual HMAC keys
# replace endpoint with COS endpoint being used
echo access_key_id:access_key_secret > ~/.passwd-s3fs
s3fs encrypted-images /mnt/cos -o url=https://s3.direct.us-south.cloud-object-storage.appdomain.cloud -o passwd_file=~/.passwd-s3fs
echo "encrypted-images /mnt/cos fuse.s3fs _netdev,allow_other,url=https://s3.direct.us-south.cloud-object-storage.appdomain.cloud 0 0" >> /etc/fstab
