#!/usr/bin/env bash

set -e 

if [ -z "$ENVIRONMENT" ]; then
  echo "environment variable (ENVIRONMENT) not set"
  exit 1
fi

if [ ! -f "$KUBE_CONFIG_FILE" ]; then
  echo "No kubeconfig found in $KUBE_CONFIG_FILE"
  echo "Please ensure kubeconfig file is created"
  exit 1
fi

if [ -z "$NAMESPACE" ]; then
  printf "${ERROR}environment variable (NAMESPACE) not set"
  exit 1
fi
