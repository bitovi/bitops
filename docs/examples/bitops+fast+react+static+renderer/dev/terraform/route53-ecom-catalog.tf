resource "aws_route53_record" "catalog" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name_catalog
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.catalog_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.catalog_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}