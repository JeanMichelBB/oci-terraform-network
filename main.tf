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
  dns_label           = "mysubnet"
}

resource "oci_core_instance" "my_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  display_name        = "my-instance"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.my_subnet.id
    display_name              = "my-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "myhostname"
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

resource "oci_load_balancer_load_balancer" "example_load_balancer" {
  compartment_id = var.compartment_id
  display_name   = "example_load_balancer"
  shape          = "100Mbps"
  subnet_ids     = [oci_core_subnet.my_subnet.id] # Your existing subnet
}

resource "oci_load_balancer_listener" "test_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.test_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.example_load_balancer.id
  name                      = "test_listener"
  port                      = 80
  protocol                  = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = 120
  }
}

resource "oci_load_balancer_backend_set" "test_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.example_load_balancer.id
  name             = "test_backend_set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol              = "HTTP"
    url_path              = "/"
    interval_ms           = 10000
    timeout_in_millis     = 3000
    retries               = 3
    return_code           = 200
    is_force_plain_text   = false
    response_body_regex   = "OK"
  }

  session_persistence_configuration {
    cookie_name = "JSESSIONID"
  }
}

resource "oci_load_balancer_backend" "test_backend" {
  load_balancer_id = oci_load_balancer_load_balancer.example_load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.test_backend_set.name
  ip_address       = oci_core_instance.my_instance.private_ip
  port             = 80
}