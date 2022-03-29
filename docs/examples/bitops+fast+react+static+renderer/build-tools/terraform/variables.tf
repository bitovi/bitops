variable "common_tags" {
  description = "Common tags you want applied to all components."
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_cloudwatch_retention_in_days" {
  type        = number
  description = "AWS CloudWatch Logs Retention in Days"
  default     = 1
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "image_registry_url" {
  description = "Base URL of the image registry"
}
variable "image_registry_image" {
  description = "Registry image name"
}
variable "image_registry_tag" {
  description = "Registry image tag"
}
variable "iam-ci-user" {
  description = "IAM name for Service Account"
}

# Contentful secrets
variable "secret_arn_contentful_access_token" {
  description = "ARN for the contentful access token"
}
variable "secret_arn_contentful_space_id" {
  description = "ARN for the contentful space id"
}

# build app vars for react
variable "app_version_react" {
  description = "APP_VERSION env var for react"
}
variable "app_subpath_react" {
  description = "APP_SUBPATH env var for react"
}
variable "s3_bucket_contents_react" {
  description = "S3_BUCKET_CONTENTS env var for react"
}
variable "app_subpath_publish_suffix_react" {
  description = "APP_SUBPATH_PUBLISH_SUFFIX env var for react"
}
variable "publish_s3_bucket_react" {
  description = "PUBLISH_S3_BUCKET env var for react"
}
variable "build_output_subdirectory_react" {
  description = "BUILD_OUTPUT_SUBDIRECTORY env var for react"
}
variable "cloudfront_distribution_id_react" {
  description = "CLOUDFRONT_DISTRIBUTION_ID env var for react"
}

# build app vars for angular
variable "app_version_angular" {
  description = "APP_VERSION env var for angular"
}
variable "app_subpath_angular" {
  description = "APP_SUBPATH env var for angular"
}
variable "s3_bucket_contents_angular" {
  description = "S3_BUCKET_CONTENTS env var for angular"
}
variable "app_subpath_publish_suffix_angular" {
  description = "APP_SUBPATH_PUBLISH_SUFFIX env var for angular"
}
variable "publish_s3_bucket_angular" {
  description = "PUBLISH_S3_BUCKET env var for angular"
}
variable "build_output_subdirectory_angular" {
  description = "BUILD_OUTPUT_SUBDIRECTORY env var for angular"
}
variable "cloudfront_distribution_id_angular" {
  description = "CLOUDFRONT_DISTRIBUTION_ID env var for angular"
}

