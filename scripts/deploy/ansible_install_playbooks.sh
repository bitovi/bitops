#!/usr/bin/env bash

set -e  

function run_ansible_playbooks() {
    path=""

    if [ -z "$ANSIBLE_DIRECTORY" ]
    then 
        echo "Ansible directory not set. Using default directory."
        path="$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/ansible"
    else
        path="$CURRENT_ENVIRONMENT/$ANSIBLE_DIRECTORY/"
        echo "Using provided Ansible directory: $path"
    fi
    
    echo "Using Ansible Path: $path"
    for playbook in $(ls $path/*.yaml || ls $path/*.yml)
    do 
        echo "Executing playbook: $playbook"
        /root/.local/bin/ansible-playbook $playbook
    done
}

run_ansible_playbooks
