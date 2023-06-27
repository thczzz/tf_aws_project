resource "aws_db_instance" "vprofile-rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7.42"
  instance_class         = "db.t2.micro"
  db_name                = var.dbname
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql5.7"
  multi_az               = "false"
  publicly_accessible    = "false"
  skip_final_snapshot    = true
  db_subnet_group_name   = data.terraform_remote_state.remote.outputs.vprofile-rds-subnet-grp-name
  # db_subnet_group_name   = aws_db_subnet_group.vprofile-rds-subnet-grp.name
  vpc_security_group_ids = [data.terraform_remote_state.remote.outputs.vprofile-backend-sg-id]
  # vpc_security_group_ids = [aws_security_group.vprofile-backend-sg.id]
}

resource "aws_elasticache_cluster" "vprofile-cache" {
  cluster_id           = "vprofile-cache-${random_id.id.hex}"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = data.terraform_remote_state.remote.outputs.vprofile-ecache-subnet-grp-name
  # subnet_group_name    = aws_elasticache_subnet_group.vprofile-ecache-subnet-grp.name
  security_group_ids   = [data.terraform_remote_state.remote.outputs.vprofile-backend-sg-id]
  # security_group_ids   = [aws_security_group.vprofile-backend-sg.id]
}

resource "aws_mq_broker" "vprofile-rmq" {
  broker_name        = "vprofile-rmq-${random_id.id.hex}"
  engine_type        = "ActiveMQ"
  engine_version     = "5.17.2"
  host_instance_type = "mq.t2.micro"
  security_groups    = [data.terraform_remote_state.remote.outputs.vprofile-backend-sg-id]
  # security_groups    = [aws_security_group.vprofile-backend-sg.id]
  subnet_ids         = [data.terraform_remote_state.remote.outputs.vpc-private_subnets[0]]
  # subnet_ids         = [module.vpc.private_subnets[0]]

  user {
    username = var.rmquser
    password = var.rmqpass
  }
}
