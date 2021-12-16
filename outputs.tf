output "vpc_name" {
  description = "VPC Name"
  value       = module.vpc.name
}
output "vpc_private_subnets" {
  description = "Private subnets IDs"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnets" {
  description = "Public subnets IDs"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "Database subnets"
  value       = module.vpc.database_subnets
}

output "db_instance_availability_zone" {
  description = "DB instance availability zones"
  value       = module.db.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "DB instance endpoint"
  value       = module.db.db_instance_endpoint
}

