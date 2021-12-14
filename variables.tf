variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "wordpress_vpc"
}

variable "vpc_tags" {
  description = "VPC tags"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "wordpress-demo"
  }
}

variable "vpc_azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.16.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default     = ["10.16.48.0/20", "10.16.112.0/20", "10.16.176.0/20"]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.16.96.0/20",
    "10.16.144.0/20",
    "10.16.160.0/20"
  ]
}
variable "db_subnets" {
  description = "Database private subnets"
  type        = list(string)
  default     = ["10.16.16.0/20", "10.16.32.0/20", "10.16.80.0/20"]
}

# Database variables

variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "wordpressdb"
}
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "5.7.31"
}

variable "db_family" {
  description = "Database family"
  type        = string
  default     = "mysql5.7"
}

variable "major_engine_version" {
  description = "Database major engine version"
  type        = string
  default     = "5.7"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.m5.large"
}

variable "storage" {
  description = "Database allocated storage"
  type        = string
  default     = "5"
}

# EC2 wordpress app variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
variable "ec2_keypair" {
  type    = string
  default = "homelab2022"

}

# ELB attachments
variable "number_of_instances" {
  description = "Number of instances to create and attach to ELB"
  type        = string
  default     = 1
}