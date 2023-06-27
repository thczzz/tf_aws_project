terraform {
  backend "s3" {
    bucket = "vprofile-kops-state-343"
    key    = "terraform/initial_setup_state"
    region = "us-east-1"
  }
}
