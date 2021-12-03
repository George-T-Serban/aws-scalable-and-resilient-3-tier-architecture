output "vpc_name" {
    description = "VPC Name"
    value = module.vpc.name
}
output "vpc_private_subnets" {
    description = "Private subnets IDs"
    value = module.vpc.private_subnets
}

output "vpc_public_subnets" {
    description = "Public subnets IDs"
    value = module.vpc.public_subnets
}

    
# }