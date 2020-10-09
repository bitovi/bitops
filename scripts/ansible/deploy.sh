#!/usr/bin/env bash
set -e

export ANSIBLE_ROOT="$ENVROOT/ansible" 
export ANSIBLE_BITOPS_CONFIG="$ANSIBLE_ROOT/bitops.config.yaml" 
export BITOPS_SCHEMA_ENV_FILE="$ANSIBLE_ROOT/ENV_FILE"
export BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/ansible/bitops.schema.yaml"



if [ ! -d "$ANSIBLE_ROOT" ]; then
  echo "No ansible directory.  Skipping."
  exit 0
else
  printf "Deploying ansible... ${NC}"
fi


if [ -f "$ANSIBLE_BITOPS_CONFIG" ]; then
  echo "Ansible - Found BitOps config"
else
  echo "Ansible - No BitOps config"
fi

echo "cd Ansible Root: $ANSIBLE_ROOT"
cd $ANSIBLE_ROOT

bash $SCRIPTS_DIR/deploy/before-deploy.sh "$ANSIBLE_ROOT"

export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $ANSIBLE_BITOPS_CONFIG)"
echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
echo "BITOPS_SCHEMA_ENV_FILE: $(cat $BITOPS_SCHEMA_ENV_FILE)"
source "$BITOPS_SCHEMA_ENV_FILE"

bash $SCRIPTS_DIR/ansible/validate_env.sh


echo "Running Ansible Playbooks"
bash -x $SCRIPTS_DIR/ansible/ansible_install_playbooks.sh "$BITOPS_CONFIG_COMMAND"

bash $SCRIPTS_DIR/deploy/after-deploy.sh "$ANSIBLE_ROOT"