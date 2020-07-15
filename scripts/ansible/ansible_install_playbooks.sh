#!/usr/bin/env bash

set -ex

apt-get install mysql-client

PLUGIN_DIR="$ENVROOT/ansible"

if [ -d "$PLUGIN_DIR/bitops.before-deploy.d/" ];then
    BEFORE_DEPLOY=$(ls $PLUGIN_DIR/bitops.before-deploy.d/)
    echo $BEFORE_DEPLOY
    if [[ -n ${BEFORE_DEPLOY} ]];then
        echo "Running Before Deploy Scripts"
        for script in $BEFORE_DEPLOY ; do
            if [[ -x "$PLUGIN_DIR/bitops.before-deploy.d/$script" ]]; then
                /bin/bash -x $PLUGIN_DIR/bitops.before-deploy.d/$script
            else
                echo "Before deploy script is not executible. Skipping..."
            fi
        done
    fi
fi

echo "Running ansible_install_playbook.sh"

echo "Using Ansible Path: $PLUGIN_DIR"
for playbook in $(ls $PLUGIN_DIR/*.yaml || ls $PLUGIN_DIR/*.yml)
do
    echo "Executing playbook: $playbook"
    /root/.local/bin/ansible-playbook $playbook
done
