# Build Image Server

### Documentation
- Documentation of Snapshot:  [https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning](https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning)  
- Documentation of IBM Cloud CLI: [https://cloud.ibm.com/docs/cli?topic=cli-getting-started](https://cloud.ibm.com/docs/cli?topic=cli-getting-started).   


### Pre-reqs:
1. IBM Databases for Redis provisioned and available in source region.  REDIS is used to maintain work queue between nodes and processes.  Minimum configuration acceptable.  https://cloud.ibm.com/catalog/services/databases-for-redis.
    * Redis Service name
    * Redis username/password
2. IBM Cloud Object Storage service provisioned, with bucket created in destination region. Cross-region prefered if available for source/destination region.
    * HMAC Keys for COS Bucket with write access to import bucket
    * COS Private Endpoint for bucket & bucket name
    * COS URI for Image Import https://cloud.ibm.com/docs/vpc?topic=vpc-managing-images
3. IBM Cloud VPC authorized to access Cloud Object Storage Bucket. https://cloud.ibm.com/docs/vpc?topic=vpc-object-storage-prereq
4. IBM Cloud API Key with access to create snapshot images, import VPC custom images, and manage REDIS database
5. IBM Cloud API Key for Terraform to provision conversion server stored in env variable (export IC_API_KEY=)
6. IBM Github Enterprise personal access token to download repository scripts.    

## Steps
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
3.  Modify variable.tf with VPC, Subnet, Server Names, and other desired variables such as snapshot region, recovery region, etc.
    * replace Region, VPC name, Zone, Subnet and resource group to match where you want conversion server deployed.  This does not need to be the same VPC or zone where snapshots will be taken.  It does need to be the same reigon.
    * Modify Server Name, and Server Count.  Count will determine how many servers will be provisioned to run conversions.
    * Modify instance profile and image to be used.   These should not need to be mofified.
    * Modify recovery region, snapshot region to match desired source and destination for snapshots
    * Modify cosbucket to match bucket location in image import format. 
    * Modify COS URI for which script will write converted images two.
4.  Issue `terraform init`
5.  Issue `terraform plan`
6.  Issue `terraform apply`