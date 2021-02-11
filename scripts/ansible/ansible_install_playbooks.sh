#!/usr/bin/env bash
set -e

ANSIBLE_ARGS=$1
PLUGIN_DIR="$ENVROOT/ansible"
EXTRA_ENV="$PLUGIN_DIR/extra_env"

if [ -f "$EXTRA_ENV" ]; then
  echo "Ansible - Found extra_env. Exporting additional configuration variables."
  set -a
  source $EXTRA_ENV
  set +a
else
  echo "Ansible - No extra_env file detected for Ansible. Skipping"
fi

echo "Running ansible_install_playbook.sh for $PLUGIN_DIR"

for playbook in $(ls $PLUGIN_DIR/*[^bitops.config].yaml || ls $PLUGIN_DIR/*[^bitops.config].yml); do
    echo "Executing playbook: $playbook"
    ansible-playbook $playbook $ANSIBLE_ARGS
done