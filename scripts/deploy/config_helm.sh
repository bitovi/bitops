#!/usr/bin/env bash
set -e 

function config_helm() {
    i=0
    while [ $i -lt $(shyaml get-value helm < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l) ]
    do
      HELM_ACTION=$(shyaml get-value helm.actions.$i.enabled < "$TEMPDIR/bitops.config.default.yaml")
      HELM_ACTION_NAME=$(shyaml get-value helm.actions.$i.name < "$TEMPDIR/bitops.config.default.yaml")
      if [ "$HELM_ACTION" == True ]
      then
          if [ $HELM_ACTION_NAME == "deploy_charts" ]
          then
              DEPLOY_HELM="true"
              echo "$DEPLOY_HELM"
          fi
      fi
      i=$(($i+1))
    done
}

config_helm
