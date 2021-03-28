
Documentation of Snapshot (appears to be accessible publicly)
https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning
 
Documentation of IBM Cloud CLI
https://cloud.ibm.com/docs/cli?topic=cli-getting-started. 

<li>setup-image-server.sh installs the required plugins, tools, etc and formats the work volume for a centos based server to be used for the image-conversion copy.</li>
<li>create-image.sh is the script which will create a snapshot based on server name, mount a volume based on snapshot, create image from volume, covnert RAW image to QCOW2, and write to COS so it can be imported into remote image library in different region.</li>
<li>get-boot-vol.sh is a script which given a server-name and region, will return the associated instance-id, boot-volume-id, latest snapshot-id, and the original OS version of boot volume image.</li>
<li>snapshot.sh is a script which given a server-name and region, will create a snapshot of boot volume to be used within-region</li>

 restore-from-image.tf is an example Terraform v0.14 plan to deploy an instance from the imported image.   Modification of variables is required to select placement of region, zone, subnet, and IP.

 
 
