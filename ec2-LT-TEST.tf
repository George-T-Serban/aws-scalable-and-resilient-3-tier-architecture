# Create public amazon-linux-2 Ec2 instance 1
resource "aws_instance" "amz-public-1" {

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]


  launch_template {
    id = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
    }

  depends_on = [module.db, aws_efs_file_system.efs_wp, aws_efs_mount_target.wp_mnt_target]
    
  tags = {
    Name  = "public-1"
    "Env" = "prod"
  }
}
