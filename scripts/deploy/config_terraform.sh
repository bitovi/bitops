#!/usr/bin/env bash

set -e 

function config_terraform() {
    echo "Running terraform config"
    count=$(shyaml get-value terraform.actions < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $(shyaml get-value terraform.actions < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l) ]
    do
      TF_ACTION=$(shyaml get-value terraform.actions.$i.enabled < "$TEMPDIR/bitops.config.default.yaml")
      TF_ACTION_NAME=$(shyaml get-value terraform.actions.$i.name < "$TEMPDIR/bitops.config.default.yaml")
      if [ "$TF_ACTION" == True ]
      then
          if [ $TF_ACTION_NAME == "terraform_plan" ]
          then
              echo "Setting TF_PLAN to true"
              export PLAN="true"
          fi

          if [ $TF_ACTION_NAME == "terraform_apply" ]
          then
              echo "Setting TF_APPLY to true"
              export APPLY="true"
          fi 

          if [ $TF_ACTION_NAME == "terraform_destroy" ]
          then
              export DESTROY="true"
          fi
          echo "Debug"
          echo "TF_ACTION_NAME: $TF_ACTION_NAME, action set to: $TF_ACTION"
          echo ""
      fi
      i=$(($i+1))
    done
}
