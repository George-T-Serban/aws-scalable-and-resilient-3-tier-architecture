# This is the EC2 wordpress launch template

# Get the latest amazon-linux-2 AMI id
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

# Create launch template
resource "aws_launch_template" "wordpress_launch_template" {
    name = "wordpress_launch_template"    

    image_id = data.aws_ami.amazon-linux-2.id
    instance_type = var.instance_type
    key_name = var.ec2_keypair    

    network_interfaces {
      delete_on_termination = true
      subnet_id = module.vpc.public_subnets[0]
      security_groups = [aws_security_group.allow_ssh.id]
    }

    placement {
      availability_zone = var.vpc_azs[0]
    }
    
    user_data = filebase64("wp-install.sh")

}
