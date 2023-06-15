# This is the s3 bucket that will house the static sites
resource "aws_s3_bucket" "s3_static_files" {
  bucket                  = "bitovi-operations-cheetah-sites"
  acl                     = "public-read"

  policy = templatefile("templates/s3-policy.json", { bucket = "bitovi-operations-cheetah-sites" })
  tags = {
    Name                      = "bitovi-operations-cheetah-sites"
    terraform                 = "true"
    OperationsRepo            = "operations-cheetah"
    OperationsRepoEnvironment = "global-tools"
  }

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    # allowed_origins = ["https://www.${var.domain_name}"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}