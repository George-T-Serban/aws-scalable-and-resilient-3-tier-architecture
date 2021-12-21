# This is the EC2 wordpress launch template

# Create security group to allow HTTP/HTTPS traffic and SSH from whithin the VPC only.
resource "aws_security_group" "lt_sg" {
  name        = "Allow ssh,HTTP,HTTPS"
  description = "Allow HTTP and HTTPS. SSH from within the VPC only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

# Create the Launch Template.
resource "aws_launch_template" "wordpress_launch_template" {
  name = "wordpress_launch_template"

  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name      = var.ec2_keypair

  network_interfaces {
    delete_on_termination = true
    subnet_id             = module.vpc.public_subnets[0]
    security_groups       = [aws_security_group.lt_sg.id]
  }

  iam_instance_profile {
    arn = "arn:aws:iam::648826012845:instance-profile/terraform-wordpress-demo-EC2"
  }

  user_data = filebase64("wp-install.sh")

  depends_on = [aws_rds_cluster.wp_cluster,aws_rds_cluster_instance.cluster_instances,
                aws_efs_file_system.efs_wp, aws_efs_mount_target.wp_mnt_target, aws_lb.wp_alb
               ]

}
