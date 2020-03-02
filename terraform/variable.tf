variable "profile" {
  description = "AWS User account Profile"
  default = "default"
}

variable "region" {
  default = "us-east-2"
}

variable "key" {
  description = "EC2 Key"
  default = "ihillaws-ohio2"
}

variable "sub_ids" {
  default = []
}

variable "instance-ami" {
  default = "ami-0e38b48473ea57778" # AMI of Mumbai region
}

variable "instance_type" {
  default = "t3.medium"
}


variable "cluster-name" {
  default = "BitOps"
}

variable "server-name" {
  description = "Ec2 Server Name"
  default = "BitOps"
}

variable "vpc_name" {
  description = "VPC name"
  default = "bitops"
}
  
