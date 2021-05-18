variable "ibmcloud_region" {
  description = "IBM Cloud region to use for your infrastructure"
  default = "us-south"
}

variable "vpc_name" {
  default = "us-south-my-vpc"
  description = "Name of your VPC"
}

variable "zone1" {
  default = "us-south-2"
  description = "Define zone of region to deploy to"
}

variable "vpc_subnet" {
  default = "us-south-2-default-subnet"
  description = "Define subnet for network connection."
}

variable "vpc_zone1_cidr" {
  default = "10.241.64.0/21"
  description = "CIDR Block to assignt to zone."
}

variable "vpc_zone1_subnet" {
  default = "10.241.64.0/24"
  description = "Subnet for Zone1 Subnet 1"
}

variable "resourcegroup_name" {
  default = "default"
  description = "Resource group for Server."
}

variable "server-name1" {
  default = "test-server01"
  description = "Server Name to be used"
}

variable "ip1" {
  default = "10.241.64.101"
  description = "Subnet IP address to be assigned."
}

variable "server-name2" {
  default = "test-server02"
  description = "Server Name to be used"
}

variable "ip2" {
  default = "10.241.64.102"
  description = "Subnet IP address to be assigned."
}

variable "server-name3" {
  default = "test-server03"
  description = "Server Name to be used"
}

variable "ip3" {
  default = "10.241.64.103"
  description = "Subnet IP address to be assigned."
}

variable "server-name4" {
  default = "test-server04"
  description = "Server Name to be used"
}

variable "ip4" {
  default = "10.241.64.104"
  description = "Subnet IP address to be assigned."
}

variable "server-name5" {
  default = "test-server05"
  description = "Server Name to be used"
}

variable "ip5" {
  default = "10.241.64.105"
  description = "Subnet IP address to be assigned."
}

variable "server-name6" {
  default = "test-server06"
  description = "Server Name to be used"
}

variable "ip6" {
  default = "10.241.64.106"
  description = "Subnet IP address to be assigned."
}

variable "server-name7" {
  default = "test-server07"
  description = "Server Name to be used"
}

variable "ip7" {
  default = "10.241.64.107"
  description = "Subnet IP address to be assigned."
}

variable "server-name8" {
  default = "test-server08"
  description = "Server Name to be used"
}

variable "ip8" {
  default = "10.241.64.108"
  description = "Subnet IP address to be assigned."
}

variable "instance_profile" {
  default =  "bx2-2x8"
  description = "Instance profile to be used for virtual instances"
}