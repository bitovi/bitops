#!/usr/bin/env bash
set -e

echo "aws eks update-kubeconfig"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region $AWS_DEFAULT_REGION --kubeconfig "$KUBECONFIG"