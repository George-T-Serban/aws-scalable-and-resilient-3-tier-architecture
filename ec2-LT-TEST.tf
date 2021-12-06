# Create public amazon-linux-2 Ec2 instance 1
resource "aws_instance" "amz-public-1" {
  
launch_template {
  id = aws_launch_template.wordpress_launch_template.id
  version = "$Latest"
  }

  tags = {
    Name  = "public-1"
    "Env" = "prod"
  }
}
