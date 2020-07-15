#!/usr/bin/env bash

set -e

if [[ ${ANSIBLE_PLAYBOOKS} == "true" ]]; then
    echo "Running Ansible Playbooks"
    bash -x $SCRIPTS_DIR/ansible/ansible_install_playbooks.sh
fi 