# # locals.tf
# locals {
#   subnet_cidr_blocks = {
#     public    = module.subnets.network_cidr_blocks["public"]
#     private   = module.subnets.network_cidr_blocks["private"]
#     database  = module.subnets.network_cidr_blocks["database"]
#     elasticache = module.subnets.network_cidr_blocks["elasticache"]
#   }
# }