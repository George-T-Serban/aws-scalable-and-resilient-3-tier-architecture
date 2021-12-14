# Create public amazon-linux-2 Ec2 instance 1
resource "aws_instance" "wordpress_app" {


  launch_template {
    id      = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
  }

  depends_on = [module.db, aws_efs_file_system.efs_wp, aws_efs_mount_target.wp_mnt_target]

  tags = {
    Name  = "wordrpress-app"
    "Env" = "demo"
  }
}
