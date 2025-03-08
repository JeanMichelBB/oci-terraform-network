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
  # dns_label      = "myvcn"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

output "availability_domain_name" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

resource "oci_core_subnet" "my_subnet" {
  cidr_block     = "10.0.1.0/24"
  display_name   = "my-subnet"
  compartment_id = var.compartment_id
  vcn_id = oci_core_vcn.main.id 
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}


data "oci_core_images" "ubuntu_image" {
  compartment_id = var.compartment_id
  operating_system = "Ubuntu"
  operating_system_version = "22.04"
  shape = "VM.Standard2.1.Micro"  
}

output "ubuntu_image_id" {
  value = data.oci_core_images.ubuntu_image.images[0].id
}

resource "oci_core_instance" "my_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard2.1.Micro"
  display_name        = "Ubuntu-Instance"

  create_vnic_details {
    subnet_id = oci_core_subnet.my_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_image.images[0].id
  }

  metadata = {
    ssh_authorized_keys = base64decode(var.private_key)
  }
}

resource "oci_core_volume" "my_volume" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "my-volume"
  size_in_gbs         = 50
}

resource "oci_core_volume_attachment" "my_volume_attachment" {
  instance_id    = oci_core_instance.my_instance.id
  volume_id      = oci_core_volume.my_volume.id
  attachment_type = "iscsi"
}