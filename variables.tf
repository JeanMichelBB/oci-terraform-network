# // variables.tf
variable "fingerprint" {
  type        = string
  description = "OCI API Key Fingerprint"
}

variable "private_key" {
  type        = string
  description = "Private Key for OCI API"
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