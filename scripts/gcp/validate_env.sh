#!/usr/bin/env bash
set -e 

# export REGISTRY_HOSTNAME=gcr.io
# export PROJECT=${PROJECT_ID}
# export EMAIL=${SERVICE_ACCOUNT_EMAIL}
# export ZONE=${GKE_ZONE}
# export CLUSTER=bitops-cluster
# export ZONE="us-central1-c"

if [ -z "$GCP_PROJECT" ]; then
  printf "${ERROR}environment variable (GCP_PROJECT) not set ${NC}"
  exit 1
fi
if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
  printf "${ERROR}environment variable (SERVICE_ACCOUNT_EMAIL) not set ${NC}"
  exit 1
fi
if [ -z "$GCP_DEFAULT_REGION" ]; then
  printf "${ERROR}environment variable (GCP_DEFAULT_REGION) not set ${NC}"
  exit 1
fi
if [ -z "$GCP_ZONE" ]; then
  printf "${ERROR}environment variable (GCP_ZONE) not set ${NC}"
  exit 1
fi