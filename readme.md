# Using Snapshot Beta to create Cross Region Images

### Documentation
- Documentation of Snapshot:  [https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning](https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning)  
- Documentation of IBM Cloud CLI: [https://cloud.ibm.com/docs/cli?topic=cli-getting-started](https://cloud.ibm.com/docs/cli?topic=cli-getting-started).   


### General Assumptions:
1 IBM Cloud CLI has been installed along with VPC Infrastructure plugin  
2 API key with Administrator authority downloaded and accessible at ~/apikey.json  
3 VPC Infrastructure authorization (Reader & Writer Role) to COS instance where images will be stored  
4 s3fsfuse installed and configured with HMAC keys with writer access to destination COS bucket stored at ~/passwd.s3fs   

### CLI Commands
>     snapshot                                                    [Beta] View details of a snapshot  
>     snapshot-create, snapshotc                                  [Beta] Create a snapshot from a volume  
>     snapshot-delete, snapshotd                                  [Beta] Delete snapshots  
>     snapshot-delete-from-source, snapshotsd, snapshots-delete   [Beta] Delete snapshots by source volume  
>     snapshot-update, snapshotu                                  [Beta] Update a snapshot  
>     snapshots                                                   [Beta] List all snapshots  

### Image conversion process
- **create-image.sh <server>** creates a snapshot based on a server name, mounts a new volume created from the snapshot,converts to QCOW2, and then imports it into remote image library in other region.  
- **create-image-background.sh** runs in the background, using a REDIS queue, executes image-conversion jobs in the background.  Can be used to run multiple current conversion jobs, and to scale horizontally to multiple servers
- **add-server.sh <server>** add server to REDIS queue to be converted by create-image-background.sh.

1. Initiate a snapshot of specified server boot volume
2. Create volume from snapshot and attaches to image server
3. Waits for volume to be attached and accessiblem, determins device attach location (/dev/vdX)
4. Executed `qemu-img conver` to read RAW volume and write compressed QCOW2 image to COS bucket
5. Imports newly created image as server-latest from COS bucket into image library 
6. If existing image exists in Library, renames to server-created_at_date
7. Detach volume used for image and delete

### Terraform
Terraform v0.14.10 IBM Cloud Plugin >= 1.21.   
Plans in each directory provide a sampe of how to build and recover servers from created images.  Variables should be configured as needed.
- **build-image-server** Terraform plan to create conversion server(s). Change variables.tf to appropriate VPC, Subnet, and server names desired.   Currently you need to manually deploy S3 HMAC keys, IBM Cloud API key, and REDIS user/pw and certficate to each server after terraform provisions servers(s).
- **tf_create**  Terraform plan to provision 8 test servers into existing production VPC.  
- **tf_recover**  Terraform plan, after creating images and importing into alternate region, creates a VPC, Zone, and Subnet based on original VPC and provisions the 8 servers from each server-latest image.

### Other useful utilities
- **get-boot-vol.sh** returns the associated instance-id, boot-volume-id, latest snapshot-id, and the original OS version of boot volume image.  
- **snapshot.sh** creates a snapshot of boot volume to be used within-region.  


### known limitations
- even though temporary volume is created with auto-delete=true, volumes are not automatically deleted on detach.  Script currently manually deletes all volumes.
- script does not delete COS images
- script does not delete old image library images
- cos image names:  latest image for each server is always prepended with -latest, older images named with image-import date (does not match snapshot date)
