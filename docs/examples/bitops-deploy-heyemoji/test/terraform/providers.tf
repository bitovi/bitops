terraform {
    required_version = ">= 0.12"
    backend "s3" {
        bucket = "heyemoji-blog"
        key = "state"
    }
}

provider "local" {
    version = "~> 1.2"
}

provider "null" {
    version = "~> 2.1"
}

provider "template" {
    version = "~> 2.1"
}

provider "aws" {
    version = ">= 2.28.1"
    region  = "us-east-2"
}