# // variables.tf

variable "region" {
  description = "The OCI region to deploy to."
}

variable "cidr" {
  description = "The CIDR block for the VCN."
}

variable "azs" {
  description = "A list of availability zones."
  type = list(string)
}

variable "name" {
  description = "The name of the network."
}

variable "compartment_id" {
  description = "The OCI compartment ID."
}