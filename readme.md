# Using Snapshot Beta to create Cross Region Images

### Documentation
- Documentation of Snapshot:  [https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning](https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning)  
- Documentation of IBM Cloud CLI: [https://cloud.ibm.com/docs/cli?topic=cli-getting-started](https://cloud.ibm.com/docs/cli?topic=cli-getting-started).   

### CLI Commands used
>     snapshot                                                    [Beta] View details of a snapshot  
>     snapshot-create, snapshotc                                  [Beta] Create a snapshot from a volume  
>     snapshot-delete, snapshotd                                  [Beta] Delete snapshots  
>     snapshot-delete-from-source, snapshotsd, snapshots-delete   [Beta] Delete snapshots by source volume  
>     snapshot-update, snapshotu                                  [Beta] Update a snapshot  
>     snapshots                                                   [Beta] List all snapshots  

### Image conversion process
- **create-image.sh** Using a REDIS queue, executes image-conversion jobs in the background.  Can be used to run multiple current conversion jobs, and to scale horizontally to multiple servers
- **start-background-process.sh** starts multiple background create-image processes.  Started by systemd image-process service at boot.
- **add-server.sh <server>** add a server to REDIS queue to be converted by create-image-background.sh.

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

- **build-image-server** Terraform plan to create conversion server(s). 
- **tf_create**  Terraform plan to provision 8 test servers into existing production VPC for testing.  
- **tf_recover**  Terraform plan, after creating images and importing into alternate region, creates a VPC, Zone, and Subnet based on original VPC and provisions the 8 servers from each server-latest image.

### Other useful utilities
- **get-boot-vol.sh** returns the associated instance-id, boot-volume-id, latest snapshot-id, and the original OS version of boot volume image.  
- **snapshot.sh** creates a snapshot of boot volume to be used within-region.  


### known limitations
- even though temporary volume is created with auto-delete=true, volumes are not automatically deleted on detach.  Script manually deletes volumes until issue is resolved.
- script does not delete COS images
- script does not delete old image library images
- script does not prune/delete old snapshots

