

resource "aws_route53_record" "root-react" {
  zone_id = var.bitovi-cheetah.com-zone-id
  name    = var.subdomain_name_react
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.react_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.react_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}