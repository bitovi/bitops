#!/usr/bin/env bash

set -e 

function config_root_values() {
    echo "Running config root values."
    export SECRETS_MGR=$(cat bitops.config.default.yaml| shyaml get-value secrets_manager.value)
    export IMG_REPO=$(cat bitops.config.default.yaml| shyaml get-value image_repository.value)
    export CURRENT_ENVIRONMENT=$(cat bitops.config.default.yaml| shyaml get-value environment.default)
    echo "SECRETS_MGR: $SECRETS_MGR, IMG_REPO: $IMG_REPO, CURRENT_ENVIRONMENT: $CURRENT_ENVIRONMENT"
}


function config_ansible() {
    echo "Running anisble config"
    count=$(cat bitops.config.default.yaml| shyaml get-value ansible | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $count ]
    do
      ANSIBLE_ACTION=$(cat bitops.config.default.yaml| shyaml get-value ansible.actions.$i.enabled)
      ANSIBLE_ACTION_NAME=$(cat bitops.config.default.yaml| shyaml get-value ansible.actions.$i.name)
      if [ "$ANSIBLE_ACTION" == True ]
      then
          if [ $ANSIBLE_ACTION_NAME == "deploy_playbooks" ]
          then
              echo "Setting DEPLOY_ANSIBLE to true"
              echo ""
              export ANSIBLE_PLAYBOOKS="true"
          fi

          if [ $ANSIBLE_ACTION_NAME == "override_default" ]
          then
              export ANSIBLE_DIRECTORY=$(cat bitops.config.default.yaml| shyaml get-value ansible.actions.$i.ansible_directory)
              echo "OVERRIDE_ANSIBLE_DIRECTORY set to: $ANSIBLE_DIRECTORY"
              echo ""
          fi
      fi
      i=$(($i+1))
    done
}

# read configuration from config file.
config_root_values 
config_cloud_platform 
config_terraform 
config_helm 
config_ansible