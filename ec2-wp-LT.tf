# This is the EC2 wordpress launch template

# Create security group to allow ssh
resource "aws_security_group" "allow_ssh" {
  name        = "allow ssh"
  description = "Allow ssh from any IP"
  vpc_id      = module.vpc.vpc_id
  

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

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
