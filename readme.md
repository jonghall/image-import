# Using Snapshot to create Cross Region Images

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
- **setup-image-server.sh** installs the required plugins, tools, etc and formats the work volume for a centos based server to be used for the image-conversion copy.  
- **create-image.sh**  creates a snapshot based on a server name, mounts a new volume created from the snapshot, creates RAW image from volume and convert and uploads QCOW2 image to a COS bucket, and then imports it into remote image library other region.  
- **get-boot-vol.sh** returns the associated instance-id, boot-volume-id, latest snapshot-id, and the original OS version of boot volume image.  
- **snapshot.sh** creates a snapshot of boot volume to be used within-region.  

### Terraform
- **provider.tf** configures the appropriate IBM Cloud provider variables and downloads latest IBM Cloud provider plugin.  
- **restore-from-image.tf** is an example Terraform v0.14 plan to deploy an instance from an imported image name.   Modification of variables is required to select placement of region, zone, subnet, and IP.  
m-image.tf** is an example Terraform v0.14 plan to deploy an instance from an imported image name.   Modification of variables is required to select placement of region, zone, subnet, and IP.  .14 plan to deploy an instance from an imported image name.   Modification of variables is required to select placement of region, zone, subnet, and IP.