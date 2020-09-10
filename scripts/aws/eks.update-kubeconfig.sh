#!/usr/bin/env bash
set -e

echo "/root/.local/bin/aws eks update-kubeconfig"
/root/.local/bin/aws eks update-kubeconfig --name "$CLUSTER_NAME" --region $AWS_DEFAULT_REGION --kubeconfig "$KUBECONFIG"