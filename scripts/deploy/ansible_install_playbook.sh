#!/usr/bin/env bash

set -e  

function run_ansible_playbooks() {
    path=""

    if [ -z "$ANSIBLE_DIRECTORY" ]
    then 
        echo "Ansible directory not set. Using default directory."
        path="$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/ansible"
    else
        echo "Using provided Ansible directory: $ANSIBLE_DIRECTORY"
        path="$CURRENT_ENVIRONMENT/$ANSIBLE_DIRECTORY/"
    fi
    /root/.local/bin/ansible-playbook $path
}