data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = var.remote_state_key
    region = "us-east-1"
  }
}

