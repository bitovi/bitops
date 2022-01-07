#!/bin/bash
echo "I am a before cloudformation lifecycle script!"
#aws s3api create-bucket --bucket "$CFN_TEMPLATE_S3_BUCKET" --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true
