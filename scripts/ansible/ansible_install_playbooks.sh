#!/usr/bin/env bash

set -e  

echo "Running ansible_install_playbook.sh"
PLAYBOOK_FILE="playbook.yml"
/root/.local/bin/ansible-playbook "$PLAYBOOK_FILE"

# echo "Using Ansible Path: $path"
# for playbook in $(ls $path/*.yaml || ls $path/*.yml)
# do 
#     echo "Executing playbook: $playbook"
#     /root/.local/bin/ansible-playbook $playbook
# done
