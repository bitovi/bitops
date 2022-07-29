common_tags = {
  OperationsRepo = "bitovi/operations-cheetah"
  OperationsRepoEnvironment = "build-tools"
}

image_registry_url      =  "368433847371.dkr.ecr.us-west-2.amazonaws.com"
image_registry_image    =  "ecom"
image_registry_tag      =  "latest"
aws_region        = "us-west-2"

# these are zones and subnets examples
availability_zones = ["us-west-2a","us-west-2b"]
public_subnets     = ["10.10.100.0/24", "10.10.101.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24"]

# Contentful secrets
secret_arn_contentful_access_token = "arn:aws:secretsmanager:us-west-2:368433847371:secret:ContentfulAccessToken-8FMXFR"
secret_arn_contentful_space_id = "arn:aws:secretsmanager:us-west-2:368433847371:secret:ContentfulSpaceID-zlbGTJ"

# these are used for tags
app_name        = "ecom-build"
app_environment = "build-tools"


app_subpath_react = "react"
app_version_react = "latest"
s3_bucket_contents_react = "bitovi-operations-cheetah-lambda"
app_subpath_publish_suffix_react = ""
publish_s3_bucket_react = "bitovi-operations-cheetah-sites"
build_output_subdirectory_react = "out"
cloudfront_distribution_id_react = "E1P5X4XDUERR45"

app_subpath_angular = "angular"
app_version_angular = "latest"
s3_bucket_contents_angular = "bitovi-operations-cheetah-lambda"
app_subpath_publish_suffix_angular = ""
publish_s3_bucket_angular = "bitovi-operations-cheetah-sites"

# TODO: should this be: dist/static ?
build_output_subdirectory_angular = "dist/apps/cheetah"
cloudfront_distribution_id_angular = "E34450W1O9P7SH"
