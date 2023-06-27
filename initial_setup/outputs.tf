output "vprofile-rds-subnet-grp-name" {
  value = aws_db_subnet_group.vprofile-rds-subnet-grp.name
}

output "vprofile-backend-sg-id" {
  value = aws_security_group.vprofile-backend-sg.id
}

output "vprofile-ecache-subnet-grp-name" {
  value = aws_elasticache_subnet_group.vprofile-ecache-subnet-grp.name
}

output "vpc-private_subnets" {
  value = module.vpc.private_subnets
}

output "beanstalk_application-name" {
  value = aws_elastic_beanstalk_application.vprofile-prod.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc-public_subnets" {
  value = module.vpc.public_subnets
}

output "vprofile-ec2-prod-sg-id" {
  value = aws_security_group.vprofile-ec2-prod-sg.id
}

output "vprofile-bean-elb-sg-id" {
  value = aws_security_group.vprofile-bean-elb-sg.id
}

output "vprofile-bastion-sg-id" {
  value = aws_security_group.vprofile-bastion-sg.id
}

