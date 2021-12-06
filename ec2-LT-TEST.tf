# Create public amazon-linux-2 Ec2 instance 1
resource "aws_instance" "amz-public-1" {

  iam_instance_profile = "terraform-wordpress-demo-EC2"
  
  launch_template {
    id = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
    }

  provisioner "local-exec" {
    command = "terraform output -raw vpc_name > test-outputs"
  }
  
  tags = {
    Name  = "public-1"
    "Env" = "prod"
  }
}
