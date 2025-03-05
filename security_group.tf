# // security_group.tf

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "public_security_list"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "private_security_list"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}
resource "oci_core_network_security_group" "web_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "web_nsg"
}

resource "oci_core_network_security_group" "app_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "app_nsg"
}

# Attach NSG to compute instances
resource "oci_core_instance" "web_instance" {
  compartment_id = var.compartment_id
  availability_domain = var.azs[0]
  shape            = "VM.Standard2.1"
  display_name     = "web_instance"
  image_id         = var.image_id
  subnet_id        = oci_core_subnet.public_subnet[0].id

  network_security_group_ids = [oci_core_network_security_group.web_nsg.id]
}

resource "oci_core_instance" "app_instance" {
  compartment_id = var.compartment_id
  availability_domain = var.azs[1]
  shape            = "VM.Standard2.1"
  display_name     = "app_instance"
  image_id         = var.image_id
  subnet_id        = oci_core_subnet.private_subnet[0].id

  network_security_group_ids = [oci_core_network_security_group.app_nsg.id]
}
