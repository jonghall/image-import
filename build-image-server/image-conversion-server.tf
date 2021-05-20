
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


####################################################
# Create secondary Temp volume for conversion      #
####################################################
resource "ibm_is_volume" "volume" {
  count = var.server-count
  name     = "tmp-${format("%02s",count.index+1)}"
  profile  = "general-purpose"
  zone     = var.zone1
  capacity = 100
  resource_group  = data.ibm_resource_group.rg.id
}

######################################
# Image conversion Server build      #
######################################
resource "ibm_is_instance" "server1" {
  count = var.server-count
  name    = "${var.server-name}${format("%02s",count.index+1)}"
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile
  volumes = [element(ibm_is_volume.volume.*.id, count.index+1)]
  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
  user_data = data.template_cloudinit_config.cloud-init.rendered
}
