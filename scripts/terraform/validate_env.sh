#!/usr/bin/env bash

set -e 

if [ -z "$ENVIRONMENT" ]; then
  echo "environment variable (ENVIRONMENT) not set"
  exit 1
fi

if  [ ! -f "$KUBE_CONFIG_FILE" ] && [[ ${TERRAFORM_APPLY} == "false" ]] && [[ ${TEST} == "false" ]]; then
  printf "${ERROR} You did not supply a kubeconfig and you have chosen not to create a cluster.\n
  To create a cluster, set the environment variable TERRAFORM_APPLY to true.${NC} "
  exit 1
fi

if [ ! -f "$KUBE_CONFIG_FILE" ] && [ -z "$TERRAFORM_APPLY" ]; then
  printf "${WARN}TERRAFORM_APPLY and KUBECONFIG is empty...
  Either supply KUBECONFIG_BASE64 or set TERRAFORM_APPLY to true...${NC}"
fi


