# Route 53 for domain
resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = var.common_tags
}