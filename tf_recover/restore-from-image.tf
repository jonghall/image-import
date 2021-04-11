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

variable "resourcegroup_name" {
  default = "default"
  description = "Resource group for Server."
}

variable "server-name1" {
  default = "test-server01"
  description = "Server Name to be used"
}

variable "ip1" {
  default = "172.20.0.101"
  description = "Subnet IP address to be assigned."
}

variable "server-name2" {
  default = "test-server02"
  description = "Server Name to be used"
}

variable "ip2" {
  default = "172.20.0.102"
  description = "Subnet IP address to be assigned."
}

variable "server-name3" {
  default = "test-server03"
  description = "Server Name to be used"
}

variable "ip3" {
  default = "172.20.0.103"
  description = "Subnet IP address to be assigned."
}

variable "server-name4" {
  default = "test-server04"
  description = "Server Name to be used"
}

variable "ip4" {
  default = "172.20.0.104"
  description = "Subnet IP address to be assigned."
}

variable "server-name5" {
  default = "test-server05"
  description = "Server Name to be used"
}

variable "ip5" {
  default = "172.20.0.105"
  description = "Subnet IP address to be assigned."
}

variable "server-name6" {
  default = "test-server06"
  description = "Server Name to be used"
}

variable "ip6" {
  default = "172.20.0.106"
  description = "Subnet IP address to be assigned."
}

variable "server-name7" {
  default = "test-server07"
  description = "Server Name to be used"
}

variable "ip7" {
  default = "172.20.0.107"
  description = "Subnet IP address to be assigned."
}

variable "server-name8" {
  default = "test-server08"
  description = "Server Name to be used"
}

variable "ip8" {
  default = "172.20.0.108"
  description = "Subnet IP address to be assigned."
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

data "ibm_is_image" "image1" {
  name = "${var.server-name1}-latest"
}

data "ibm_is_image" "image2" {
  name = "${var.server-name2}-latest"
}

data "ibm_is_image" "image3" {
  name = "${var.server-name3}-latest"
}

data "ibm_is_image" "image4" {
  name = "${var.server-name4}-latest"
}

data "ibm_is_image" "image5" {
  name = "${var.server-name5}-latest"
}

data "ibm_is_image" "image6" {
  name = "${var.server-name6}-latest"
}

data "ibm_is_image" "image7" {
  name = "${var.server-name7}-latest"
}

data "ibm_is_image" "image8" {
  name = "${var.server-name8}-latest"
}

######################################
# Restored Server                    #
######################################
resource "ibm_is_instance" "server1" {
  name    = var.server-name1
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image1.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip1
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server1" {
  name = "fip-${var.server-name1}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server1.primary_network_interface[0].id
}

resource "ibm_is_instance" "server2" {
  name    = var.server-name2
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image2.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip2
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server2" {
  name = "fip-${var.server-name2}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server2.primary_network_interface[0].id
}

resource "ibm_is_instance" "server3" {
  name    = var.server-name3
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image3.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip3
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server3" {
  name = "fip-${var.server-name3}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server3.primary_network_interface[0].id
}

resource "ibm_is_instance" "server4" {
  name    = var.server-name4
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image4.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip4
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server4" {
  name = "fip-${var.server-name4}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server4.primary_network_interface[0].id
}

resource "ibm_is_instance" "server5" {
  name    = var.server-name5
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image5.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip5
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server5" {
  name = "fip-${var.server-name5}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server5.primary_network_interface[0].id
}

resource "ibm_is_instance" "server6" {
  name    = var.server-name6
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image6.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip6
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server6" {
  name = "fip-${var.server-name6}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server6.primary_network_interface[0].id
}

resource "ibm_is_instance" "server7" {
  name    = var.server-name7
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image7.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip7
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server7" {
  name = "fip-${var.server-name7}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server7.primary_network_interface[0].id
}

resource "ibm_is_instance" "server8" {
  name    = var.server-name8
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image8.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip8
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server8" {
  name = "fip-${var.server-name8}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server8.primary_network_interface[0].id
}







