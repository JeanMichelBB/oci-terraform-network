# // security_group.tf
resource "oci_core_network_security_group" "db_sg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Database Security Group"
}

resource "oci_core_network_security_group" "private_sg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Private Security Group"
}

resource "oci_core_network_security_group_security_rule" "allow_db_private" {
  network_security_group_id = oci_core_network_security_group.db_sg.id
  direction                = "INGRESS"
  protocol                 = "6"  # TCP
  source_type              = "NETWORK_SECURITY_GROUP"
  source                   = oci_core_network_security_group.private_sg.id
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
}