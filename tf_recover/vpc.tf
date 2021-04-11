#---------------------------------------------------------
# Create new VPC
#---------------------------------------------------------

resource "ibm_is_vpc" "vpc" {
  name                = var.recovery_vpc"
  resource_group      = data.ibm_resource_group.rg.id
  address_prefix_management = "manual"
}

#---------------------------------------------------------
# Create new address prefixes in VPC for Zone 1 & Zone 2
#---------------------------------------------------------
resource "ibm_is_vpc_address_prefix" "prefix1-vpc-a-zone-a" {
  name = "${var.vpc-a-name}-${var.zone-a}-cidr-prefix-1"
  vpc  = "${ibm_is_vpc.vpc-a.id}"
  zone = "${var.zone-a}"
  cidr = "${var.address-prefix-vpc-a-zone-a}"
}

resource "ibm_is_vpc_address_prefix" "prefix1-vpc-a-zone-b" {
  name = "${var.vpc-a-name}-${var.zone-b}-cidr-prefix-1"
  vpc  = "${ibm_is_vpc.vpc-a.id}"
  zone = "${var.zone-b}"
  cidr = "${var.address-prefix-vpc-a-zone-b}"
}

resource "ibm_is_vpc_address_prefix" "prefix1-vpc-a-zone-c" {
  name = "${var.vpc-a-name}-${var.zone-c}-cidr-prefix-1"
  vpc  = "${ibm_is_vpc.vpc-a.id}"
  zone = "${var.zone-c}"
  cidr = "${var.address-prefix-vpc-a-zone-c}"
}


#---------------------------------------------------------
# Get Public Gateway's for Zone 1 & Zone 2
#---------------------------------------------------------
resource "ibm_is_public_gateway" "pubgw-vpc-a-zone-a" {
  name = "${var.vpc-a-name}-${var.zone-a}-pubgw"
  resource_group = "${data.ibm_resource_group.group.id}"
  vpc  = "${ibm_is_vpc.vpc-a.id}"
  zone = "${var.zone-a}"
  provisioner "local-exec" {
    command = "sleep 60"
    when    = "destroy"
  }
}

resource "ibm_is_public_gateway" "pubgw-vpc-a-zone-b" {
  name = "${var.vpc-a-name}-${var.zone-b}-pubgw"
  resource_group = "${data.ibm_resource_group.group.id}"
  vpc  = "${ibm_is_vpc.vpc-a.id}"
  zone = "${var.zone-b}"
  provisioner "local-exec" {
    command = "sleep 60"
    when    = "destroy"
  }
}

resource "ibm_is_public_gateway" "pubgw-vpc-a-zone-c" {
  name = "${var.vpc-a-name}-${var.zone-c}-pubgw"
  resource_group = "${data.ibm_resource_group.group.id}"
  vpc  = "${ibm_is_vpc.vpc-a.id}"
  zone = "${var.zone-c}"
  provisioner "local-exec" {
    command = "sleep 60"
    when    = "destroy"
  }
}


#---------------------------------------------------------
## Create Web and DB subnets in Zone 1 & Zone 2
#---------------------------------------------------------
resource "ibm_is_subnet" "workers-subnet-vpc-a-zone-a" {
  name            = "${var.vpc-a-name}-${var.zone-a}-workers"
  resource_group  = "${data.ibm_resource_group.group.id}"
  vpc             = "${ibm_is_vpc.vpc-a.id}"
  zone            = "${var.zone-a}"
  ipv4_cidr_block = "${var.workers-vpc-a-zone-a}"
  public_gateway  = "${ibm_is_public_gateway.pubgw-vpc-a-zone-a.id}"
}

resource "ibm_is_subnet" "workers-subnet-vpc-a-zone-b" {
  name            = "${var.vpc-a-name}-${var.zone-b}-workers"
  resource_group  = "${data.ibm_resource_group.group.id}"
  vpc             = "${ibm_is_vpc.vpc-a.id}"
  zone            = "${var.zone-b}"
  ipv4_cidr_block = "${var.workers-vpc-a-zone-b}"
  public_gateway  = "${ibm_is_public_gateway.pubgw-vpc-a-zone-b.id}"
}

resource "ibm_is_subnet" "workers-subnet-vpc-a-zone-c" {
  name            = "${var.vpc-a-name}-${var.zone-c}-workers"
  resource_group  = "${data.ibm_resource_group.group.id}"
  vpc             = "${ibm_is_vpc.vpc-a.id}"
  zone            = "${var.zone-c}"
  ipv4_cidr_block = "${var.workers-vpc-a-zone-c}"
  public_gateway  = "${ibm_is_public_gateway.pubgw-vpc-a-zone-c.id}"
}