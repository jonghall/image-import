


######################################
# Get values from Cloud              #
######################################

data "ibm_is_ssh_key" "sshkey" {
  name = "jonhall"
}

data "ibm_resource_group" "rg" {
  name = var.resourcegroup_name
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
  vpc  = ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image1.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc  = ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image2.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image3.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image4.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image5.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc  = ibm_is_vpc.vpc.id
  zone = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image6.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image7.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
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
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.zone1
  resource_group  = data.ibm_resource_group.rg.id
  image   = data.ibm_is_image.image8.id
  profile = var.instance_profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
    primary_ipv4_address = var.ip8
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "fip-server8" {
  name = "fip-${var.server-name8}"
  resource_group = data.ibm_resource_group.rg.id
  target = ibm_is_instance.server8.primary_network_interface[0].id
}
