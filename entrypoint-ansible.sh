#!/usr/bin/env bash
set -xe


export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"


if [ -z "$ENVIRONMENT" ]; then
  printf "${ERROR}environment variable (ENVIRONMENT) not set"
  exit 1
fi


if [ -d "$ENVIRONMENT/ansbile" ];
  /bin/bash $SCRIPTS_DIR/ansible/ansible_install_playbooks.sh
then
