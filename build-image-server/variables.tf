variable "ibmcloud_region" {
  description = "IBM Cloud region to build infrastructure"
  default = "au-syd"
}

variable "vpc_name" {
  default = "au-syd-default-vpc"
  description = "VPC to provision servers into"
}

variable "zone1" {
  default = "au-syd-1"
  description = "Define zone of region to deploy to"
}

variable "vpc_subnet" {
  default = "au-syd-1-default-subnet"
  description = "Define subnet for network connection."
}

variable "resourcegroup_name" {
  default = "default"
  description = "Resource group for Server."
}

variable "server-name1" {
  default = "image-conversion-server01"
  description = "Server Name to be used"
}

variable "server-count" {
  default = "1"
  description = "Number of image conversion servers."
}

variable "instance_profile" {
  default =  "bx2-2x8"
  description = "Instance profile to be used for virtual instances"
}

variable "image" {
  default = "ibm-centos-7-9-minimal-amd64-2"
  description = "Image to be used for virtual instances"
}


