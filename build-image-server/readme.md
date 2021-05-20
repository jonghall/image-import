# Build Image Server

### Pre-reqs:
1. IBM Databases for Redis provisioned and available in source region.  REDIS is used to maintain work queue between nodes and processes.  Minimum configuration acceptable.  https://cloud.ibm.com/catalog/services/databases-for-redis.
    * Redis Service name
    * Redis username/password
2. IBM Cloud Object Storage service provisioned, with bucket created in destination region. Note you must use a **regional COS bucket** in the destination region.  Cross regional can not be used with custom images.
    * HMAC Keys for COS Bucket with write access to import bucket
    * COS Private Endpoint to write to in destination region
    * COS Bucket Name to be used
3. IBM Cloud VPC authorized to access Cloud Object Storage Bucket. https://cloud.ibm.com/docs/vpc?topic=vpc-object-storage-prereq
4. IBM Cloud API Key with access to create snapshot images, import VPC custom images, and manage REDIS database
5. IBM Cloud API Key for Terraform to provision conversion server stored in env variable (export IC_API_KEY=)
6. IBM Github Enterprise personal access token to download repository scripts.    

## Build Steps
1. export IC_API_KEY=`apikey` with api key to be used by Terraform
2. Create _terraform.tfvars.json_ file in the Terraform directory to define private api keys and passwords to be used by Terraform.
````
{
  "githubtoken": "personal token for github en - uterprise used to download these scripts.",
  "apikey": "IBM Cloud API Key",
  "hmackey": "COS Bucket HMAC Key with write access",
  "hmacsecret": "COS Bucket HMAC Secret with write access",
  "redisuser": "admin",
  "redispw": "REDIS Database password",
  "redisinstance": "REDIS Database Instance name",
}
````
3.  Modify variable.tf with desired variables.
    * replace Region, VPC name, Zone, Subnet and resource group name to match where you want conversion server(s) provisioned.  This does not need to be the same VPC or zone where snapshots will be taken.  It does need to be the same region.
    * Modify Server Name, and Server Count.  Count will determine how many servers will be provisioned to run conversions.  Increase _server-count_ to change the number of concurrent processes (each server executes 2 concurrent conversions).   
    * Modify instance profile and image to be used for conversion server.  MX2 instance profiles are recommended as conversion process is memory intensive.  mx2-2x16 is adequate for two concurrent processes.  Multiple virtual servers are recommended to increase concurrency beyond 2 versus increasing instance profile size.  Script tested with CentOS 7.
    * Modify snapshot region and recovery region, to match desired source and destination for snapshots to be taken and copied to.
    * Modify cosbucket to the bucket where images will be written to and imported from in recovery region. 
    * Modify COS private URL for which script will write converted images to.
4.  Issue `terraform init`
5.  Issue `terraform plan`
6.  Issue `terraform apply`

## Run Steps
* systemd process will start 2 image-processes automatically at boot on each server.   Each will take work off of the REDIS work queue and process snapshot and image conversion requests.
* Increasing the number of servers increases the concurrency of the conversion process.   
* Servers may be deprovisioned after completion by decreasing the server_count in variable.tf and reapplying the Terraform plan.

1.  To add a snapshot to the conversion process queue run `./add-server.sh servername`, servername should match the VPC defined name of the server exactly.
2.  All actions are logged via syslog.   Failures will result in the item being removed from the queue and will not be restarted.
