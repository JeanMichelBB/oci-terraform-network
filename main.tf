# // main.tf
# Define the provider for OCI
provider "oci" {
  region = var.region
}

# Create a Virtual Cloud Network (VCN)
resource "oci_core_virtual_network" "vcn" {
  cidr_block = var.cidr
  display_name = var.name
  compartment_id = var.compartment_id
  dns_label = "vcn"
}

# Create an Internet Gateway (IGW) for the VCN
resource "oci_core_internet_gateway" "igw" {
  display_name = "internet_gateway"
  vcn_id = oci_core_virtual_network.vcn.id
  is_enabled = true
}

# Create a NAT Gateway for private subnets
resource "oci_core_nat_gateway" "nat_gateway" {
  display_name = "nat_gateway"
  vcn_id = oci_core_virtual_network.vcn.id
}

# Create subnets for different services (private, public, database, elasticache, etc.)
resource "oci_core_subnet" "public_subnet" {
  count = length(var.azs)

  display_name = "public-subnet-${var.azs[count.index]}"
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = module.subnets.network_cidr_blocks["public-${var.azs[count.index]}"]
  availability_domain = var.azs[count.index]
  route_table_id = oci_core_route_table.public_route_table.id
}

resource "oci_core_subnet" "private_subnet" {
  count = length(var.azs)

  display_name = "private-subnet-${var.azs[count.index]}"
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = module.subnets.network_cidr_blocks["private-${var.azs[count.index]}"]
  availability_domain = var.azs[count.index]
  route_table_id = oci_core_route_table.private_route_table.id
}

resource "oci_core_subnet" "database_subnet" {
  count = length(var.azs)

  display_name = "database-subnet-${var.azs[count.index]}"
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = module.subnets.network_cidr_blocks["database-${var.azs[count.index]}"]
  availability_domain = var.azs[count.index]
}

resource "oci_core_subnet" "elasticache_subnet" {
  count = length(var.azs)

  display_name = "elasticache-subnet-${var.azs[count.index]}"
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = module.subnets.network_cidr_blocks["elasticache-${var.azs[count.index]}"]
  availability_domain = var.azs[count.index]
}

# Create Route Tables for public and private subnets
resource "oci_core_route_table" "public_route_table" {
  display_name = "public_route_table"
  vcn_id = oci_core_virtual_network.vcn.id

  route_rules {
    destination = "0.0.0.0/0"
    network_gateway = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  display_name = "private_route_table"
  vcn_id = oci_core_virtual_network.vcn.id

  route_rules {
    destination = "0.0.0.0/0"
    nat_gateway = oci_core_nat_gateway.nat_gateway.id
  }
}

# Output the VCN ID and Subnet CIDR Blocks
output "vcn_id" {
  value = oci_core_virtual_network.vcn.id
}

output "public_subnet_cidrs" {
  value = [for subnet in oci_core_subnet.public_subnet : subnet.cidr_block]
}

output "private_subnet_cidrs" {
  value = [for subnet in oci_core_subnet.private_subnet : subnet.cidr_block]
}

output "database_subnet_cidrs" {
  value = [for subnet in oci_core_subnet.database_subnet : subnet.cidr_block]
}

output "elasticache_subnet_cidrs" {
  value = [for subnet in oci_core_subnet.elasticache_subnet : subnet.cidr_block]
}