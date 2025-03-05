resource "oci_core_security_group" "db_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vpc_network.id
  display_name   = "${var.name}-db"

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "db_ingress_rule" {
  security_group_id = oci_core_security_group.db_security_group.id
  direction         = "INGRESS"
  protocol          = "6"  # TCP
  source            = "0.0.0.0/0"
  tcp_options {
    min = 0
    max = 65535
  }

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "db_ingress_private" {
  security_group_id = oci_core_security_group.db_security_group.id
  direction         = "INGRESS"
  protocol          = "6"  # TCP
  source_security_group_id = oci_core_security_group.private_security_group.id
  tcp_options {
    min = 5432
    max = 5432
  }

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "db_egress_rule" {
  security_group_id = oci_core_security_group.db_security_group.id
  direction         = "EGRESS"
  protocol          = "all"
  destination       = "0.0.0.0/0"
  
  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}
resource "oci_core_security_group" "elasticache_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vpc_network.id
  display_name   = "${var.name}-elasticache"

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "elasticache_ingress_rule" {
  security_group_id = oci_core_security_group.elasticache_security_group.id
  direction         = "INGRESS"
  protocol          = "6"  # TCP
  source            = "0.0.0.0/0"
  tcp_options {
    min = 0
    max = 65535
  }

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "elasticache_ingress_private" {
  security_group_id = oci_core_security_group.elasticache_security_group.id
  direction         = "INGRESS"
  protocol          = "6"  # TCP
  source_security_group_id = oci_core_security_group.private_security_group.id
  tcp_options {
    min = 6379
    max = 6379
  }

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "elasticache_egress_rule" {
  security_group_id = oci_core_security_group.elasticache_security_group.id
  direction         = "EGRESS"
  protocol          = "all"
  destination       = "0.0.0.0/0"

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}
resource "oci_core_security_group" "private_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vpc_network.id
  display_name   = "${var.name}-private"

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "private_ingress_rule" {
  security_group_id = oci_core_security_group.private_security_group.id
  direction         = "INGRESS"
  protocol          = "6"  # TCP
  source            = "0.0.0.0/0"
  tcp_options {
    min = 0
    max = 65535
  }

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}

resource "oci_core_security_rule" "private_egress_rule" {
  security_group_id = oci_core_security_group.private_security_group.id
  direction         = "EGRESS"
  protocol          = "all"
  destination       = "0.0.0.0/0"
  
  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}
