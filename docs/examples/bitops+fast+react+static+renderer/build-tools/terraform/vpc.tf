resource "aws_vpc" "build_tools" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = var.common_tags
}