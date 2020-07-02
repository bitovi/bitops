#!/usr/bin/env bash
set -xe


export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"
export ROOT_DIR="/opt/bitops_deployment"
export ENVROOT="$ROOT_DIR/$ENVIRONMENT"

if [ -z "$ENVIRONMENT" ]; then
  printf "${ERROR}environment variable (ENVIRONMENT) not set"
  exit 1
fi


if [ -d "$ENVIRONMENT/ansible" ]; then
  /bin/bash $SCRIPTS_DIR/ansible/ansible_install_playbooks.sh
fi
