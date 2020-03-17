variable "environment" {
  description = "The environment where the stack will be launched."
  default = "prod"
}

variable "profile" {
  description = "AWS User account Profile."
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
  default = "bitops"
}

variable "vpc_name" {
  description = "VPC name"
  default = "bitops"
}

variable "cidr" {
  description = "The CIDR of the VPC"
  default  = "10.0.0.0/16"
}

variable "master_subnet_cidr" {
  description = "Subnet where the master will reside."
  type = "list"
  default = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
}

variable "worker_subnet_cidr" {
  description = "Subnet where the workers will reside."
  type = "list"
  default = ["10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR."
  type = "list"
  default = ["10.0.204.0/22", "10.0.208.0/22", "10.0.212.0/22"]
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR."
  type = "list"
  default = ["10.0.228.0/22", "10.0.232.0/22", "10.0.236.0/22"]
}

  
