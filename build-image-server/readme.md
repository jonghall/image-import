# Build Image Server

### Pre-reqs:
1. IBM Databases for Redis provisioned and available in source region.  REDIS is used to maintain work queue between nodes and processes.  Minimum configuration acceptable.  https://cloud.ibm.com/catalog/services/databases-for-redis.
    * Redis Service name
    * Redis username/password
2. IBM Cloud Object Storage service provisioned, with bucket created in destination region. Cross-region prefered if available for source/destination region.
    * HMAC Keys for COS Bucket with write access to import bucket
    * COS Private Endpoint to write to
    * COS Bucket Name to be used
3. IBM Cloud VPC authorized to access Cloud Object Storage Bucket. https://cloud.ibm.com/docs/vpc?topic=vpc-object-storage-prereq
4. IBM Cloud API Key with access to create snapshot images, import VPC custom images, and manage REDIS database
5. IBM Cloud API Key for Terraform to provision conversion server stored in env variable (export IC_API_KEY=)
6. IBM Github Enterprise personal access token to download repository scripts.    

## Build Steps
1. export IC_API_KEY with api key to be used by Terraform
2. Create _terraform.tfvars.json_ filein Terraform directly to define private api keys and passwords to be used by Terraform.
````
{
  "githubtoken": "personal token for github - used to download scripts.",
  "apikey": "IBM Cloud API Key",
  "hmackey": "COS Bucket HMAC Key with write access",
  "hmacsecret": "COS Bucket HMAC Secret with write access",
  "redisuser": "admin",
  "redispw": "REDIS Database password",
  "redisinstance": "REDIS Database Instance name",
}
````
3.  Modify variable.tf with desired variables.
    * replace Region, VPC name, Zone, Subnet and resource group name to match where you want conversion server(s) provisioned.  This does not need to be the same VPC or zone where snapshots will be taken.  It does need to be the same reigon.
    * Modify Server Name, and Server Count.  Count will determine how many servers will be provisioned to run conversions.
    * Modify instance profile and image to be used for conversin server.   These should not need to be modified. Script tested only with CentOS 7.
    * Modify snapshot region and recovery region, to match desired source and destination for snapshots
    * Modify cosbucket to the bucket images will be written to and imported from. 
    * Modify COS private URI for which script will write converted images to.
4.  Issue `terraform init`
5.  Issue `terraform plan`
6.  Issue `terraform apply`

## Run Steps
* systemd process will start 3 image-processes automatically at boot.   Each will take work off of the REDIS work queue and process.   
* Increasing the number of servers increases the concurrency of the conversion process.   
* Servers may be deprovisioned after completion by decreasing the server_count in variable.tf and reapplying the Terraform template

1.  To add server to work queue type `./add-server.sh servername`, servername should match the VPC defined name of the server.
2.  All actions are logged via syslog.   Failures will result in the item being removed from the queue and will not be restarted.
