#---------------------------------------------------------
# Create new VPC
#---------------------------------------------------------

resource "ibm_is_vpc" "vpc" {
  name                = var.vpc_name
  resource_group      = data.ibm_resource_group.rg.id
  address_prefix_management = "manual"
}

#---------------------------------------------------------
# Create new address prefixes in VPC for Zone 1
#---------------------------------------------------------
resource "ibm_is_vpc_address_prefix" "prefix1-vpc-a-zone-a" {
  name = "${var.vpc_name}-${var.zone1}-cidr-prefix-1"
  vpc  =  ibm_is_vpc.vpc.id
  zone =  var.zone1
  cidr =  var.vpc_zone1_cidr
}

#---------------------------------------------------------
# Get Public Gateway's for Zone 1 & Zone 2
#---------------------------------------------------------
resource "ibm_is_public_gateway" "pubgw-vpc-zone1" {
  name = "${var.vpc_name}-${var.zone1}-pubgw"
  resource_group = data.ibm_resource_group.rg.id
  vpc  = ibm_is_vpc.vpc.id
  zone = var.zone1
}

#---------------------------------------------------------
## Create Web and DB subnets in Zone 1 & Zone 2
#---------------------------------------------------------
resource "ibm_is_subnet" "subnet" {
  name            = "${var.vpc_name}-${var.zone1}-recovery"
  resource_group  = data.ibm_resource_group.rg.id
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zone1
  ipv4_cidr_block = var.vpc_zone1_subnet
  public_gateway  = ibm_is_public_gateway.pubgw-vpc-zone1.id}"
}