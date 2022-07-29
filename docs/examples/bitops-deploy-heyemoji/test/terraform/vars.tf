/* set up env variables */
variable "AWS_DEFAULT_REGION" {
    type        = string
    description = "AWS region"
}
variable "TF_STATE_BUCKET" {
    type        = string
    description = "Terraform state bucket"
}

