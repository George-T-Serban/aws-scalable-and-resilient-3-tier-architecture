resource "aws_security_group" "allow_ssh" {
  name        = "allow ssh traffic"
  description = "Allow ssh inbound traffic"
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

# Create public amazon-linux-2 Ec2 instance 1
resource "aws_instance" "amz-public-1" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  key_name               = var.ec2_keypair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    Name  = "public-1"
    "Env" = "prod"
  }
}
