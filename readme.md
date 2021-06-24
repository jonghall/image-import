# Using Snapshot command to create Cross Region Images

### Documentation
*IBM Cloud Snapshots Now GA (5/20/21)*
- Documentation of Snapshot:  [https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning](https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning)  
- Documentation of IBM Cloud CLI: [https://cloud.ibm.com/docs/cli?topic=cli-getting-started](https://cloud.ibm.com/docs/cli?topic=cli-getting-started).   

### CLI Commands used
>     snapshot                                                    View details of a snapshot  
>     snapshot-create, snapshotc                                  Create a snapshot from a volume  
>     snapshot-delete, snapshotd                                  Delete snapshots  
>     snapshot-delete-from-source, snapshotsd, snapshots-delete   Delete snapshots by source volume  
>     snapshot-update, snapshotu                                  Update a snapshot  
>     snapshots                                                   List all snapshots  

### Example Scripts ###
- [**snapshot.sh**](https://github.ibm.com/jonhall/image-import/blob/master/snapshot.sh) is an example shell script which uses IBMCLOUD CLI to create a boot-volume snapshot from a running server.
- [**provision.sh**](https://github.ibm.com/jonhall/image-import/blob/master/provision.sh) is an example shell script which uses IBMCLOUD CLI to provision a new server from a previously created Snapshot.
- [**get-boot-vol.sh**](https://github.ibm.com/jonhall/image-import/blob/master/get-boot-vol.sh) returns the associated instance-id, boot-volume-id, latest snapshot-id, and the original OS version of boot volume image.  

### Cross Region Image conversion process
- [**create-image.sh**](https://github.ibm.com/jonhall/image-import/blob/master/create-image.sh) Using a REDIS queue, executes image-conversion jobs and then imports converted image into the custom image library in recovery region .  Can be used to run multiple current conversion jobs, and scales horizontally to multiple servers.
- [**start-background-process.sh**](https://github.ibm.com/jonhall/image-import/blob/master/start-background-process.sh) used by Systemd to start multiple background create-image processes.  Started by systemd image-process service at boot.
- [**add-server.sh <server>**](https://github.ibm.com/jonhall/image-import/blob/master/add-server.sh) adds a server to REDIS queue to be converted by create-image process.

1. Initiate a snapshot of specified servers boot volume
2. Create volume from the snapshot and attache to image conversion server
3. Wait for volume to be attached and accessible, then determin device attach location (/dev/vdX)
4. Executed `qemu-img convert` to read RAW volume and write a compressed QCOW2 image to COS bucket mounted by s3fs-fuse.
5. Imports newly created image as server-latest into image library 
6. If existing image exists in Library, rename image to server-created_at_date
7. Detach volume used for image

### Terraform
Terraform v0.14.10 IBM Cloud Plugin >= 1.21.   
Plans in each directory provide a sample of how to build server, build test environment and recover servers from created images.  

- [**build-image-server**](https://github.ibm.com/jonhall/image-import/tree/master/build-image-server) Terraform plan to create conversion server(s). 
- [**tf_create**](https://github.ibm.com/jonhall/image-import/tree/master/tf_create)  Terraform plan to provision 8 test servers into existing production VPC for testing.  
- [**tf_recover**](https://github.ibm.com/jonhall/image-import/tree/master/tf_recover)  Terraform plan, after creating images and importing into alternate region, creates a VPC, Zone, and Subnet based on original VPC and provisions the 8 servers from each server-latest image.


### known limitations
- script does not delete COS images
- script does not delete old image library images
- script does not prune/delete old snapshots

