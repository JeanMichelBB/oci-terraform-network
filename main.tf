
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
  #   user_data = base64encode(<<-EOF
  #     #!/bin/bash
  #     apt-get update -y
  #     apt-get install -y docker.io
  #     systemctl enable --now docker

  #     # Docker login 
  #     docker login -u ${var.username} -p ${var.password}

  #     # Create the systemd service to run the React app container
  #     cat <<EOF2 > /etc/systemd/system/react-app.service
  #     [Unit]
  #     Description=React App Docker Container
  #     After=network.target

  #     [Service]
  #     ExecStartPre=/usr/bin/docker pull jeanmichelbb/oci-react:latest
  #     ExecStart=/usr/bin/docker run -p 80:80 --name react-app jeanmichelbb/oci-react:latest
  #     ExecStop=/usr/bin/docker stop react-app
  #     ExecStopPost=/usr/bin/docker rm react-app
  #     Restart=always
  #     RestartSec=5s

  #     [Install]
  #     WantedBy=multi-user.target
  #     EOF2

  #     # Reload systemd configuration, enable and start the service
  #     systemctl daemon-reload
  #     systemctl enable react-app.service
  #     systemctl start react-app.service
  # EOF
  #   )
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
