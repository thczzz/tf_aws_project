resource "aws_db_subnet_group" "vprofile-rds-subnet-grp" {
  name = "main"
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2]
  ]

  tags = {
    Name = "Subnet Group for RDS"
  }
}

resource "aws_elasticache_subnet_group" "vprofile-ecache-subnet-grp" {
  name = "vprofile-ecache-subnet-grp"
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2]
  ]

  tags = {
    Name = "Subnet Group for ElastiCache"
  }
}
