# Backend configuration is loaded early so we can't use variables


terraform {
  backend "s3" {
    region  = "us-west-2"
    bucket  = "bitovi-operations-cheetah-build-tools"
    key     = "bitovi-operations-cheetah-build-tools"
    encrypt = true #AES-256encryption
  }
}
