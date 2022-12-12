#!/bin/bash

echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$AWS_DEFAULT_REGION" --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true
