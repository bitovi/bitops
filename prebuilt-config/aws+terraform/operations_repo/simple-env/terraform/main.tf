terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.1.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "bitops-test-bucket"
    key            = "testing/test-simple.tfstate"
  }
}

provider "aws" {
  region  = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-02d1e544b84bf7502"
  instance_type = "t2.micro"

  tags = {
    Name        = "Test-Simple-Operations"
    Application = "bitops"
    State       = "testing"
    CreatedBy   = "Bitovi"
  }
}