
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
  name = "ibm-windows-server-2016-full-standard-amd64-4"
}

######################################
# Restored Server                    #
######################################
resource "ibm_is_instance" "server1" {
  name    = var.server-name1
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip1
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}


resource "ibm_is_instance" "server2" {
  name    = var.server-name2
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip2
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_instance" "server3" {
  name    = var.server-name3
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip3
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_instance" "server4" {
  name    = var.server-name4
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip4
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_instance" "server5" {
  name    = var.server-name5
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip5
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_instance" "server6" {
  name    = var.server-name6
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip6
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_instance" "server7" {
  name    = var.server-name7
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip7
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_instance" "server8" {
  name    = var.server-name8
  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip8
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}
