#!/usr/bin/env bash
set -e

function config_ansible() {
    echo "Running anisble config"
    count=$(cat bitops.config.default.yaml| shyaml get-value ansible | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $count ]
    do
      ANSIBLE_ACTION=$(cat bitops.config.default.yaml| shyaml get-value ansible.actions.$i.enabled)
      ANSIBLE_ACTION_NAME=$(shyaml get-value ansible.actions.$i.name < bitops.config.default.yaml)
      if [ "$ANSIBLE_ACTION" == True ]
      then
          if [ $ANSIBLE_ACTION_NAME == "override_default" ]
          then
              ANSIBLE_DIRECTORY=$(shyaml get-value ansible.actions.$i.ansible_directory < bitops.config.default.yaml)
              echo "OVERRIDE_ANSIBLE_DIRECTORY set to: $ANSIBLE_DIRECTORY"
              echo "$ANSIBLE_DIRECTORY"
          fi
      fi
      i=$(($i+1))
    done
}