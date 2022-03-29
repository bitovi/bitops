# Cloudfront S3 for redirect to www.
resource "aws_cloudfront_distribution" "root_s3_distribution" {
  # This points to s3
  origin {
    domain_name = var.s3_domain_name
    origin_id   = var.bucket_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    origin_path = "/${var.app_subpath}/${var.app_version}"
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [var.domain_name]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

      headers = ["Origin"]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = var.common_tags
  # tags = "${merge(var.common_tags, {cachebust_timestamp=timestamp()})}"


  # ensure we wait for the lambda to create/update
  depends_on = [data.aws_lambda_invocation.build_and_publish_static_test]

}

# TODO: move to new file
resource "null_resource" "cloudfront_root_s3_distribution" {
  depends_on = [
    aws_cloudfront_distribution.root_s3_distribution,
    data.aws_lambda_invocation.build_and_publish_static_test
  ]

  # invalidate the cloudfront distribution
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.root_s3_distribution.id} --paths \"/*\""
  }

  # tag with a timestamp for cachebusting
  triggers = {
    always_run = timestamp()
  }  
}
