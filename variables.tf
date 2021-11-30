variable "aws_region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"
}

variable "vpc_name" {
    description = "VPC name"
    type = string
    default = "wordpress_vpc"
    }

variable "vpc_tags" {
    description = "VPC tags"
    type = map(string)
    default = {
        Terraform = "true"
        Environment = "wordpress-demo"
    }
}

variable "vpc_azs" {
    description = "Availability zones"
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
    description = "VPC CIDR Block"
    type = string
    default = "10.16.0.0/16"
}

variable "public_subnet_cidr_blocks" {
    description = "Available cidr blocks for public subnets"
    type = list(string)
    default = ["10.16.48.0/20", "10.16.112.0/20", "10.16.176.0/20"]
}

variable "private_subnet_cidr_blocks" {
    description = "Available cidr blocks for private subnets"
    type = list(string)
    default = [
        "10.16.16.0/20",
        "10.16.32.0/20",
        "10.16.80.0/20",
        "10.16.96.0/20",
        "10.16.144.0/20",
        "10.16.160.0/20"
    ]
}

variable "ec2_keypair" {
    type = string
    default = "my-key"
  
}