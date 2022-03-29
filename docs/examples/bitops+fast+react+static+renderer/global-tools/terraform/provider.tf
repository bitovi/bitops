terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
  version = "~> 2.66.0"  # version changed
}

provider "random" {
  version = "~> 2.2.1"
}


