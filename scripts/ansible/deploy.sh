#!/usr/bin/env bash
set -e

export ANSIBLE_ROOT="$ENVROOT/ansible" 
export ANSIBLE_BITOPS_CONFIG="$ANSIBLE_ROOT/bitops.config.yaml" 

if [ ! -d "$ANSIBLE_ROOT" ]; then
  echo "No ansible directory.  Skipping."
  exit 0
else
  printf "Deploying ansible... ${NC}"
fi


if [ -f "$ANSIBLE_BITOPS_CONFIG" ]; then
  echo "Ansible - Found Bitops config"
else
  echo "Ansible - No Bitops config"
fi

echo "cd Ansible Root: $ANSIBLE_ROOT"
cd $ANSIBLE_ROOT

bash -x $SCRIPTS_DIR/deploy/before-deploy.sh "$ANSIBLE_ROOT"

bash $SCRIPTS_DIR/ansible/validate_env.sh

echo "Running Ansible Playbooks"
bash -x $SCRIPTS_DIR/ansible/ansible_install_playbooks.sh

bash -x $SCRIPTS_DIR/deploy/after-deploy.sh "$ANSIBLE_ROOT"