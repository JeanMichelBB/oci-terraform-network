variable "azs" {
  description = "List of availability zones (ADs) for the network"
  type        = list(string)
}

variable "cidr" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "name" {
  description = "Name of the network"
  type        = string
}