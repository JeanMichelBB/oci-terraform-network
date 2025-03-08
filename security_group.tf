# security_group.tf
resource "oci_core_security_list" "cluster_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "cluster-security-group"

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
        min = 80
        max = 80
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    tcp_options {
        min = 443
        max = 443
    }
  }
}
