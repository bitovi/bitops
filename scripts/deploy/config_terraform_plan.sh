#!/usr/bin/env bash

set -e 

function config_terraform_plan() {
    count=$(shyaml get-value terraform.actions < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $count ]
    do
      TF_ACTION=$(shyaml get-value terraform.actions.$i.enabled < "$TEMPDIR/bitops.config.default.yaml")
      TF_ACTION_NAME=$(shyaml get-value terraform.actions.$i.name < "$TEMPDIR/bitops.config.default.yaml")
      if [ "$TF_ACTION" == True ]
      then
          if [ $TF_ACTION_NAME == "terraform_plan" ]
          then
              echo "true"
          fi
      fi
      i=$(($i+1))
    done
}

config_terraform_plan