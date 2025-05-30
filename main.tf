
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
  dns_label      = "myvcn"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

output "availability_domain_name" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

resource "oci_core_subnet" "my_subnet" {
  cidr_block          = "10.0.1.0/24"
  display_name        = "my-subnet"
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.main.id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  # security_list_ids   = [oci_core_security_list.cluster_security_group.id]
  dns_label           = "mysubnet"
}

resource "oci_core_instance" "my_instance" {
  count               = var.instance_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  display_name        = "${var.instance_name}-${count.index + 1}"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.my_subnet.id
    display_name              = "my-vnic-${count.index + 1}"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "myhostname${count.index + 1}"
  }

  source_details {
    source_type             = "image"
    source_id               = var.instance_image_ocid[var.region]
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.public_key
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "my_volume" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "my-volume"
  size_in_gbs         = 50
}

resource "oci_core_volume_attachment" "my_volume_attachment" {
  instance_id     = oci_core_instance.my_instance.id
  volume_id       = oci_core_volume.my_volume.id
  attachment_type = "iscsi"
}

resource "oci_core_security_list" "cluster_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "cluster-security-group"

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "8"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
    egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id

  display_name = oci_core_vcn.main.display_name
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.main.default_route_table_id

  display_name = oci_core_vcn.main.display_name

  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway.id

    description = "Default route"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_network_security_group" "network_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = oci_core_vcn.main.display_name
}

resource "oci_core_network_security_group_security_rule" "network_security_group_rule" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  protocol                  = "1"
  source                    = "0.0.0.0/0"
}