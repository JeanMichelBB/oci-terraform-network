# // variables.tf
variable "fingerprint" {
  type        = string
  description = "OCI API Key Fingerprint"
}
variable "private_key" {
  type        = string
  description = "Base64-encoded Private Key for OCI API"
}
variable "region" {
  type        = string
  description = "OCI Region"
  default     = "ca-montreal-1"
}

variable "tenancy_ocid" {
  type        = string
  description = "OCI Tenancy OCID"
}

variable "user_ocid" {
  type        = string
  description = "OCI User OCID"
}
variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created"
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_domains" {
  description = "List of availability domains"
  type        = list(string)
  default     = ["AD-1", "AD-2", "AD-3"]
}

variable "subnet_cidrs" {
  description = "Map of subnet CIDRs"
  type        = map(string)
  default = {
    database    = "10.0.1.0/24"
    private     = "10.0.2.0/24"
    public      = "10.0.3.0/24"
  }
}
variable "instance_image_ocid" {
  type = map(string)
  default = {
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaa6apcspvi563o3a3w72v5ke3rl73zd7ozwlpd7nddncdty46gwhaa"
  }
}
variable "instance_shape" {
  type        = string
  description = "The shape of the instance"
  default     = "VM.Standard.E2.1.Micro"
}
variable "instance_ocpus" {
  default     = 1
  description = "Number of OCPUs"
  type        = number
}
variable "instance_shape_config_memory_in_gbs" {
  default     = 1
  description = "Amount of Memory (GB)"
  type        = number
}
variable "instance_name" {
  description = "Name of the instance."
  type        = string
  default = "my-instance"
}
variable "boot_volume_size_in_gbs" {
  default     = "50"
  description = "Bott volume size in GBs"
  type        = number
}