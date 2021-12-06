# Get database credentials from AWS SSM Parameter Store
# name = "aws ssm parameter name"

# Database password
data "aws_ssm_parameter" "dbpassword" {
    name = "DBPassword"
}

# Database root password
data "aws_ssm_parameter" "dbrootpassword" {
    name = DBRootPassword
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
    name = "Database access from within VPC"
    description = "Database access from within VPC"
    vpc_id = module.vpc.vpc_id

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

identifier = "wordpressdb"
skip_final_snapshot = true
deletion_protection = false

engine = "mysql"
engine_version = "5.7.34"
family = "mysql5.7"
major_engine_version = "5.7"
instance_class = "db.m5.large"

# Allocated storage in GB
allocated_storage = 5  

name = data.aws_ssm_parameter.dbname.value
username = data.aws_ssm_parameter.dbuser.value
password = data.aws_ssm_parameter.dbpassword.value
port = "3306"

multi_az = true
cross_region_replica = true
subnet_ids = module.vpc.database_subnets
vpc_security_group_ids = [aws_security_group.db_sg.id]

}