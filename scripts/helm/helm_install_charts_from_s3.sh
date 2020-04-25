#!/usr/bin/env bash

set -ex


echo "Installing charts from S3 Bucket..."

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
  return 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
  return 1
fi
if [ -z "$KUBECONFIG_BASE64" ]; then
  echo "environment variable (KUBECONFIG_BASE64) not set"
  return 1
fi
if [ -z "$HELM_CHARTS_S3_BUCKET" ]; then
  echo "environment variable (HELM_CHARTS_S3_BUCKET) not set"
  return 1
fi

helm plugin install https://github.com/hypnoglow/helm-s3.git
CHART_NAME=$(echo $HELM_CHARTS_S3_BUCKET | awk -F\, {'print $1'})
S3_BUCKET=$(echo $HELM_CHARTS_S3_BUCKET | awk -F\, {'print $2'})
helm repo add $CHART_NAME $S3_BUCKET
helm repo list
