module "subnets" {
  source  = "oracle/oci/subnets"
  version = "1.0.0"

  base_cidr_block = var.cidr

  networks = flatten([
    for k, v in local.subnets : [
      for az in var.azs : {
        name     = "${k}-${az}"
        new_bits = v
      }
    ]
  ])
}

module "vpc" {
  source  = "oracle/oci/vpc"
  version = "1.0.0"

  cidr                    = var.cidr
  azs                     = var.azs
  enable_nat_gateway      = true
  one_nat_gateway_per_az  = false
  single_nat_gateway      = true
  name                    = var.name
  private_subnets         = [for az in var.azs : module.subnets.network_cidr_blocks["private-${az}"]]
  public_subnets          = [for az in var.azs : module.subnets.network_cidr_blocks["public-${az}"]]
  database_subnets        = [for az in var.azs : module.subnets.network_cidr_blocks["database-${az}"]]
  elasticache_subnets     = [for az in var.azs : module.subnets.network_cidr_blocks["elasticache-${az}"]]
  intra_subnets           = [for az in var.azs : module.subnets.network_cidr_blocks["intra-${az}"]]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = {
    Network   = var.name
    Terraform = "terraform-oci-network"
  }
}