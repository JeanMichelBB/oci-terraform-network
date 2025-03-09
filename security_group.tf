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

  ingress_security_rules {
    protocol    = "6"
    source      = "your.trusted.ip.range/32"  # Restrict SSH access to trusted IPs
    tcp_options {
        min = 22
        max = 22
    }
  }

  ingress_security_rules {
    protocol    = "8"  
    source      = "0.0.0.0/0"
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

resource "oci_identity_user" "user" {
  compartment_id = var.compartment_id
  name           = "admin"
  description    = "Admin User"
}

resource "oci_identity_group" "group" {
  compartment_id = var.compartment_id
  name           = "Administrators"
  description    = "Administrators Group"
}

resource "oci_identity_user_group_membership" "user_group_membership" {
  user_id  = oci_identity_user.user.id
  group_id = oci_identity_group.group.id
}

output "user_id" {
  value = oci_identity_user.user.id
}

output "group_id" {
  value = oci_identity_group.group.id
}