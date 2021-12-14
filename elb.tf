# Elastic Load Balancer

# ELB security group
resource "aws_security_group" "elb_sg" {
  name        = "Allow HTTP,HTTPS"
  description = "Allow HTTP,HTTPS"
  vpc_id      = module.vpc.vpc_id

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

module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "3.0.0"

  name = "wordpress-elb"

  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.elb_sg.id]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "http"
      lb_port           = "80"
      lb_protocol       = "http"
    }
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Owner       = "wordpress-ELB"
    Environment = "demo"
  }

  # ELB attachments
  number_of_instances = var.number_of_instances
  instances           = [aws_instance.wordpress_app.id]

}
