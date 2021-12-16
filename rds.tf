# Get database credentials from AWS SSM Parameter Store
# name = "aws ssm parameter name"

# Database password
data "aws_ssm_parameter" "dbpassword" {
  name = "DBPassword"
}

# Database root password
data "aws_ssm_parameter" "dbrootpassword" {
  name = "DBRootPassword"
}
# Database user name
data "aws_ssm_parameter" "dbuser" {
  name = "DBUser"
}

# Database name
data "aws_ssm_parameter" "dbname" {
  name = "DBName"
}

# Create database security group
resource "aws_security_group" "db_sg" {
  name        = "Database access from within VPC"
  description = "Database access from within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Database access from within VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create database
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.1"

  identifier          = var.db_identifier
  skip_final_snapshot = true
  deletion_protection = false

  engine               = var.db_engine
  engine_version       = var.db_engine_version
  family               = var.db_family
  major_engine_version = var.major_engine_version
  instance_class       = var.db_instance_class

  # Allocated storage in GB
  allocated_storage = var.storage

  name     = data.aws_ssm_parameter.dbname.value
  username = data.aws_ssm_parameter.dbuser.value
  password = data.aws_ssm_parameter.dbpassword.value
  port     = "3306"

  multi_az = true
  subnet_ids = ["${module.vpc.public_subnets[0]}",
                "${module.vpc.public_subnets[1]}",
                "${module.vpc.public_subnets[2]}"
               ]
  vpc_security_group_ids = [aws_security_group.db_sg.id]

}