
data "aws_ssm_parameter" "dbpass" {
    name = "DBPassword"
}

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


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.1"

identifier = "testdb"
skip_final_snapshot = true
deletion_protection = false

engine = "mysql"
engine_version = "5.7.34"
family = "mysql5.7"
major_engine_version = "5.7"
instance_class = "db.m5.large"
allocated_storage = 5

name = "wordpressdb"
username = "george"
password = data.aws_ssm_parameter.dbpass.value
port = "3306"

multi_az = true
subnet_ids = module.vpc.database_subnets
vpc_security_group_ids = [aws_security_group.db_sg.id]


}