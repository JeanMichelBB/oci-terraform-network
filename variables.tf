# // variables.tf
variable "fingerprint" {
  type        = string
  description = "OCI API Key Fingerprint"
}
variable "private_key" {
  type        = string
  description = "Base64-encoded Private Key for OCI API"
}
variable "public_key" {
  description = "Public key for SSH access"
  type        = string
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
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaajugaw7nnxbaupq4qbleicw76r4nnnhyi7b3biblpvjog42tcmzxa"
  }
}
variable "instance_shape" {
  type        = string
  description = "The shape of the instance"
  default     = "VM.Standard.A1.Flex"
}
variable "instance_ocpus" {
  default     = 2
  description = "Number of OCPUs"
  type        = number
}
variable "instance_shape_config_memory_in_gbs" {
  default     = 12
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
variable "username" {
  description = "SSH Authorized Keys"
  type        = string
}
variable "password" {
  description = "SSH Authorized Keys"
  type        = string
}
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}