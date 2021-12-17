output "vpc_name" {
  description = "VPC Name"
  value       = module.vpc.name
}

output "vpc_AZs" {
  description = "VPC AZS"
  value = module.vpc.azs
}

output "db_instance_availability_zone" {
  description = "DB instance availability zones"
  value       = module.db.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "DB instance endpoint"
  value       = module.db.db_instance_endpoint
}

output "lb_dns_name" {
  description = "Load Balancer DNS Name"
  value = aws_lb.wp_alb.dns_name
}

output "lb_arn" {
  description = "Load Balancer arn URL"
  value = aws_lb.wp_alb.arn
}

output "EFS_id" {
  description = "EFS ID"
  value = aws_efs_file_system.efs_wp.id
}

output "EFS_nr_of_mount_targets" {
  description = "EFS Number of mount targets"
  value = aws_efs_file_system.efs_wp.number_of_mount_targets
}

output "EFS_mount_target_AZs" {
  description = "EFS Mount targets AZs"
  value = ["${aws_efs_mount_target.wp_mnt_target.*.availability_zone_name}"]
}

