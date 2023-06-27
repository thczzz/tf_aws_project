resource "aws_instance" "vprofile-bastion" {
  ami                         = lookup(var.AMIS, var.AWS_REGION)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.tfkey.key_name
  subnet_id                   = data.terraform_remote_state.remote.outputs.vpc-public_subnets[0]
  # subnet_id                   = module.vpc.public_subnets[0]
  count                       = var.instance_count
  vpc_security_group_ids      = [data.terraform_remote_state.remote.outputs.vprofile-bastion-sg-id]
  # vpc_security_group_ids      = [aws_security_group.vprofile-bastion-sg.id]
  associate_public_ip_address = "true"

  root_block_device {
    volume_size = 8
  }

  tags = {
    Name    = "vprofile-bastion-${random_id.id.hex}"
    PROJECT = "vprofile"
  }

  provisioner "file" {
    content = templatefile("templates/db_deploy.tmpl",
      {
        rds-endpoint = aws_db_instance.vprofile-rds.address,
        dbuser       = var.dbuser,
        dbpass       = var.dbpass
      }
    )
    destination = "/tmp/vprofile-dbdeploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/vprofile-dbdeploy.sh",
      "sudo /tmp/vprofile-dbdeploy.sh"
    ]
  }

  connection {
    user        = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }

  depends_on = [aws_db_instance.vprofile-rds, aws_elastic_beanstalk_environment.vprofile-bean-prod]
}
