terraform {
  required_version = ">= 1.1.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=3.63.0"
    }
  }
  backend "s3" {
    region         = "us-east-2"
    bucket         = "bitovi-terraform-remote-state"
    encrypt        = true
    # dynamodb_table = "terraform-remote-state-lock"
    key            = "test.bitops.create-cluster"
  }
}
provider "aws" {
  region = "us-east-2"
}

module "eks-cluster" {
    source                  = "../../default/terraform"
    cluster_version         = var.cluster_version
    cluster_name            = var.cluster_name

    instance_types          = var.instance_types
    node_min                = var.node_min
    node_max                = var.node_max
    node_desired            = var.node_desired
    region                  = var.region
}
