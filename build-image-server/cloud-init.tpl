#cloud-config
package_update: true
package_upgrade: true


runcmd:
 - sudo mv /var/lib/cloud/instance/scripts/apikey.json /root/.
 - sudo echo "${hmackey}:${hmacsecret}" > /root/.passwd-s3fs
 - sudo chmod 600 /root/.passwd-s3fs
 - sudo echo "export REDISUSER=${redisuser}" >> /root/.bash_profile
 - sudo echo "export REDISPW=${redispw}" >> /root/.bash_profile
 - sudo echo "export snapshot_region=${snapshot_region}" >> /root/.bash_profile
 - sudo echo "export recovery_region=${recovery_region}" >> /root/.bash_profile
 - sudo echo "export cos_bucket=${cosbucket}" >> /root/.bash_profile
 - sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
 - sudo cp scripts
 - yum -y install epel-release
 - yum -y install lvm2
 - yum -y install jq
 - yum -y install qemu-img
 - yum -y install s3fs-fuse
 - yum -y install git
 - yum -y install wget
 - echo -e "n\np\n1\n\n\nt\n8e\n\nw\n" | sudo fdisk /dev/vdd
 - sudo pvcreate /dev/vdd1
 - sudo vgcreate vol_grp1 /dev/vdd1
 - sudo lvcreate -l 100%FREE -n lv_tmp vol_grp1
 - sudo mkfs.xfs  /dev/vol_grp1/lv_tmp
 - sudo mkdir /mnt/cos
 - sudo echo "/dev/mapper/vol_grp1-lv_tmp /tmp xfs defaults 0 0" >> /etc/fstab
 - sudo echo "${cosbucket} /mnt/cos fuse.s3fs _netdev,allow_other,url=${cosendpoint} 0 0" >> /etc/fstab
 - sudo echo "export importurl=cos://${recovery_region}/${cosbucket}" >> /root/.bash_profile
 - sudo mount -a
 - cd /root
 - curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
 - ibmcloud plugin install infrastructure-service -f
 - ibmcloud plugin install cloud-databases -f
 - ibmcloud login --apikey @/root/apikey.json -r ${snapshot_region}
 - ibmcloud cdb deployment-cacert ${redisinstance} --endpoint-type private --save
 - sudo echo "export REDIS_CERTFILE=/root/$(ibmcloud cdb cxn ${redisinstance} --endpoint-type private --json | jq -r '.[].cli.environment.REDIS_CERTFILE')" >> /root/.bash_profile
 - rediss=$(ibmcloud cdb cxn ${redisinstance} --endpoint-type private --json | jq '.[].rediss')
 - sudo echo "export REDISURL=$(echo $rediss | jq -r '.hosts[0].hostname'):$(echo $rediss | jq -r '.hosts[0].port')$( echo $rediss | jq -r '.path')" >> /root/.bash_profile
 - wget https://github.com/IBM-Cloud/redli/releases/download/v0.5.2/redli_0.5.2_linux_amd64.tar.gz
 - tar zxvf redli_0.5.2_linux_amd64.tar.gz
 - sudo chmod +x redli
 - sudo mv redli /usr/local/bin
 - rm redli_0.5.2_linux_amd64.tar.gz -f
 - git clone https://${githubtoken}:x-oauth-basic@github.ibm.com/jonhall/image-import.git
 - sudo mv /var/lib/cloud/instance/scripts/image-process.service /etc/systemd/system/.
 - sudo chmod 640 /etc/systemd/system/image-process.service
 - sudo systemctl start image-process
 - sudo systemctl enable image-process
