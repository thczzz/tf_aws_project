variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AMIS" {
  type = map(any)
  default = {
    # Ubuntu 20.04
    us-east-1 = "ami-0261755bbcb8c4a84"
    us-east-2 = "ami-0430580de6244e02e"
  }
}

variable "PRIV_KEY_PATH" {
  default = "tf-key"
}

variable "PUB_KEY_PATH" {
  default = "tf-key.pub"
}

variable "USERNAME" {
  default = "ubuntu"
}

variable "MYIP" {
  default = "82.103.99.58/32"
}

variable "rmquser" {}

variable "rmqpass" {}

variable "dbname" {}

variable "dbuser" {}

variable "dbpass" {}

variable "instance_count" {
  default = "1"
}

variable "remote_state_bucket_name" {
  default = "vprofile-kops-state-343"
}

variable "remote_state_key" {
  default = "terraform/initial_setup_state"
}

variable "GITHUB_BRANCH_NAME" {
  type = string
}

variable "exclude_beanstalk_env" {
  type = bool
  default = false
}
