#!/usr/bin/env bash
set -e

PLUGIN_DIR="$ENVROOT/ansible"

echo "Running ansible_install_playbook.sh for $PLUGIN_DIR"

bash -x $SCRIPTS_DIR/deploy/before-deploy.sh "$PLUGIN_DIR"

for playbook in $(ls $PLUGIN_DIR/*.yaml || ls $PLUGIN_DIR/*.yml); do
    echo "Executing playbook: $playbook"
    ansible-playbook $playbook
done