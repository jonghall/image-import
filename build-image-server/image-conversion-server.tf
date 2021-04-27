
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
  name =  var.image
}

data "local_file" "cloud-config" {
  filename = "${path.module}/cloud-init.txt"
}
####################################################
# Create secondary Temp volume for conversion      #
####################################################
resource "ibm_is_volume" "volume" {
  name     = "tmp-volume"
  profile  = "10iops-tier"
  zone     = var.zone1
  capacity = 250
  resource_group  = data.ibm_resource_group.rg.id
}

######################################
# Image conversion Server build      #
######################################
resource "ibm_is_instance" "server1" {
  count = var.server-count
  name    = "${var.server-name1}${format("%02s",count.index+1)}"
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile
  volumes = [ibm_is_volume.volume.id]
  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
  user_data = data.local_file.cloud-config.content
}
