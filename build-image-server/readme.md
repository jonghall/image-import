# Build Image Server

### Documentation
- Documentation of Snapshot:  [https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning](https://cloud.ibm.com/docs/vpc?topic=vpc-snapshots-vpc-planning)  
- Documentation of IBM Cloud CLI: [https://cloud.ibm.com/docs/cli?topic=cli-getting-started](https://cloud.ibm.com/docs/cli?topic=cli-getting-started).   


### General Assumptions:
1. IBM Cloud API Key with access to create snapshots, access REDIS database
2. REDIS Instance provisioned in Snapshot Region  
3. COS Bucket created in recovery region
    * HMAC Keys for COS BUcket with write access
    * COS Private Endpoint
    * COS URI for Image Import
    

Create _terraform.tfvars.json_ file to define private api keys and passwords in Terraform directory.
````
{
 "githubtoken": "personal token for github - used to download scripts.",
  "apikey": "IBM Cloud API Key",
  "hmackey": "COS Bucket HMAC Key with write access",
  "hmacsecret": "COS Bucket HMAC Secret with write access",
  "redisuser": "admin",
  "redispw": "REDIS Database password",
  "redisinstance": "REDIS Database Instance name",
  "redisurl": "REDIS Database URL with Port"
}
````
4.  Modify variable.tf with VPC, Subnet, Server Names, and other desired variables such as snapshot region, recovery region, etc.
5.  Issue `terraform init`
6.  Issue `terraform plan`
7.  Issue `terraform apply`