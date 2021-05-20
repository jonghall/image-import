variable "ibmcloud_region" {
  description = "IBM Cloud region to build infrastructure"
  default = "us-east"
}

variable "vpc_name" {
  default = "us-east-my-vpc"
  description = "VPC to provision servers into"
}

variable "zone1" {
  default = "us-east-2"
  description = "Define zone of region to deploy to"
}

variable "vpc_subnet" {
  default = "us-east-2-default-subnet"
  description = "Define subnet for network connection."
}

variable "resourcegroup_name" {
  default = "default"
  description = "Resource group for Server."
}

variable "server-name" {
  default = "image-conversion-server"
  description = "Server Name to be used"
}

variable "server-count" {
  default = "1"
  description = "Number of image conversion servers."
}

variable "instance_profile" {
  default =  "mx2-2x16"
  description = "Instance profile to be used for virtual instances"
}

variable "image" {
  default = "ibm-centos-7-9-minimal-amd64-3"
  description = "Image to be used for virtual instances"
}

variable  "snapshot_region" {
  default = "us-east"
  description = "Location of environment to take snapshots."
}

variable "recovery_region" {
  default = "us-south"
  description = "Location of environment to recover snapshots."
}

variable "cosbucket" {
  default = "snapshots-us-south"
  description = "COS Bucket to load images from."
}

variable "cosendpoint" {
  default = "https://s3.direct.us-south.cloud-object-storage.appdomain.cloud"
  description = "URL for cos endpoint to save images to."
}

variable "githubtoken" {
  type = string
  sensitive = true
}

variable "apikey" {
  type = string
  sensitive = true
}
variable "redisuser" {
   type = string
}

variable "redispw" {
  type = string
  sensitive = true
}

variable "hmackey" {
  type = string
  sensitive = true
}

variable "hmacsecret" {
  type = string
  sensitive = true
}

variable "redisinstance" {
  type = string
}
