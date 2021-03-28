variable "ibmcloud_region" {
  description = "IBM Cloud region to use for your infrastructure"
  default = "us-south"
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

######################################
# Get values from Cloud              #
######################################

data "ibm_is_ssh_key" "sshkey" {
  name = "jonhall"
}

data "ibm_resource_group" "rg" {
  name = var.resourcegroup_name
}

data "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

data "ibm_is_subnet" "subnet" {
  name = var.vpc_subnet
}

data "ibm_is_image" "image" {
  name = var.image_name
}

######################################
# Restored Server                    #
######################################
resource "ibm_is_instance" "server" {
  name    = var.server-name
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server" {
  name = "fip-${var.server-name}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server.primary_network_interface[0].id
}