resource "aws_ecr_repository" "bitovi" {
  name                 = "ecom"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}