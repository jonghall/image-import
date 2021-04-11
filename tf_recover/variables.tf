variable "ibmcloud_region" {
  description = "IBM Cloud region to use for your infrastructure"
  default = "us-south"
}

variable "recovery_vpc" {
  description = "Name of VPC to recover instances to"
  default = "recovery_vpc"
}

variable "vpc_name" {
  default = "vpcprod"
  description = "Name of your VPC"
}

variable "zone1" {
  default = "us-south-1"
  description = "Define zone of region to deploy to"
}

variable "vpc_subnet" {
  default = "production-subnet01"
  description = "Define subnet for network connection."
}

variable "server-name" {
  default = "restored"
  description = "Server Name to be used"
}

variable "resourcegroup_name" {
  default = "default"
  description = "Resource group for Server."
}

variable "ip" {
  default = "172.20.0.100"
  description = "Subnet IP address to be assigned."
}

variable "image_name" {
  default = "windows-test-202103280859"
  description = "Imported Image Name to be used for virtual instance"
}

variable "instance_profile" {
  default =  "bx2-2x8"
  description = "Instance profile to be used for virtual instances"
}