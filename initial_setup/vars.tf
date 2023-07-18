variable "AWS_REGION" {
  default = "us-east-1"
}

variable "MYIP" {
  default = ""
}

variable "instance_count" {
  default = "1"
}

variable "VPC_NAME" {
  default = "tfProjectVpc"
}

variable "ZONE1" {
  default = "us-east-1a"
}

variable "ZONE2" {
  default = "us-east-1b"
}

variable "ZONE3" {
  default = "us-east-1c"
}

variable "VPC_CIDR" {
  default = "172.21.0.0/16"
}

variable "PUB_subnet1_CIDR" {
  default = "172.21.1.0/24"
}

variable "PUB_subnet2_CIDR" {
  default = "172.21.2.0/24"
}

variable "PUB_subnet3_CIDR" {
  default = "172.21.3.0/24"
}

variable "PRIV_subnet1_CIDR" {
  default = "172.21.4.0/24"
}

variable "PRIV_subnet2_CIDR" {
  default = "172.21.5.0/24"
}

variable "PRIV_subnet3_CIDR" {
  default = "172.21.6.0/24"
}
