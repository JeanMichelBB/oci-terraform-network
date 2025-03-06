provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = base64decode(var.private_key)
  region       = var.region
}
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr
  display_name   = "MyVCN"
}
resource "oci_core_subnet" "database" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.subnet_cidrs["database"]
  display_name   = "Database Subnet"
  dns_label      = "dbsubnet"
}

resource "oci_core_subnet" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.subnet_cidrs["private"]
  display_name   = "Private Subnet"
  dns_label      = "privatesubnet"
}

resource "oci_core_subnet" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.subnet_cidrs["public"]
  display_name   = "Public Subnet"
  dns_label      = "publicsubnet"
  security_list_ids = [oci_core_security_list.public.id]  # Attach the security list to this subnet
  route_table_id    = oci_core_route_table.public_rt.id
}
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Internet Gateway"
}
resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "NAT Gateway"
}
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Public Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}
resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Private Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat.id
  }
}
# Define a security list for public access (if needed)
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Public Security List"

  egress_security_rules {
    destination = "0.0.0.0/0"
    stateless   = false
    protocol    = "all"
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    stateless   = false
    protocol    = "all"
    tcp_options {
      min = 80
      max = 80
    }
  }
}