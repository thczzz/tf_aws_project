resource "aws_s3_object" "application_properties" {
  bucket  = "vprofile-kops-state-343"
  key     = "terraform/${var.GITHUB_BRANCH_NAME}_env/secrets/application.properties"
  content = templatefile("templates/application.properties_deploy.tmpl",
    {
      db_host            = aws_db_instance.vprofile-rds.address,
      dbuser             = var.dbuser,
      dbpass             = var.dbpass,
      memcached_host     = aws_elasticache_cluster.vprofile-cache.cluster_address,
      rmq_host           = aws_mq_broker.vprofile-rmq.instances.0.ip_address,
      rmq_port           = 5671,
      rmq_username       = var.rmquser,
      rmq_password       = var.rmqpass
      beanstalk_env_name = aws_elastic_beanstalk_environment.vprofile-bean-prod.name
    }
  )

  depends_on = [
    aws_db_instance.vprofile-rds,
    aws_elasticache_cluster.vprofile-cache,
    aws_mq_broker.vprofile-rmq,
    aws_elastic_beanstalk_environment.vprofile-bean-prod,
  ]
}
