variable "domain_name" {
  type        = string
  description = "The domain name for the website."

}
variable "s3_domain_name" {
  type        = string
  description = "The domain name given by s3"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "bucket_prefix" {
  description = "This value should be the commit hash of an artifact directory (one that pushes stuff to s3)."
}

variable "common_tags" {
  description = "Common tags you want applied to all components."
}

variable "subdomain_name_angular" {
  description = "nomenclature for angular subdomain."
}

variable "subdomain_name_react" {
  description = "nomenclature for react subdomain."
}


variable "bitovi-cheetah.com-zone-id" {
  description = "zone id for the bitovi-cheetah.com zone"
}

variable "app_subpath_angular" {
  description = "This value should correspond to the root directory in the s3 bucket for angular"
}

variable "app_version_angular" {
  description = "This value should correspond subdirectory of the angular subpath"
}


variable "app_subpath_react" {
  description = "This value should correspond to the root directory in the s3 bucket for react"
}

variable "app_version_react" {
  description = "This value should correspond subdirectory of the react subpath"
}
