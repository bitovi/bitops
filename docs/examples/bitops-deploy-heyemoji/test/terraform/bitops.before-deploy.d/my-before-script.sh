#!/bin/bash
aws s3api create-bucket --bucket heyemoji-blog --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true