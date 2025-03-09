# main.tf
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
  dns_label = "my-vcn-dns"
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
  dns_label           = "my-subnet-dns" 
}

resource "oci_core_instance" "my_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  display_name        = replace(title(var.instance_name), "/\\s/", "")

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.my_subnet.id
    display_name              = format("%sVNIC", replace(title(var.instance_name), "/\\s/", ""))
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = lower(replace(var.instance_name, "/\\s/", ""))
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