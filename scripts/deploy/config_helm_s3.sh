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
          if [ $HELM_ACTION_NAME == "helm_s3_repo" ]
          then
              URL=$(shyaml get-value helm.actions.$i.url < "$TEMPDIR/bitops.config.default.yaml")
              CHART_NAME=$(shyaml get-value helm.actions.$i.chart_name < "$TEMPDIR/bitops.config.default.yaml")
              HELM_CHARTS_S3=$CHART_NAME,$URL
              echo "$HELM_CHARTS_S3"
          fi 
      fi
      i=$(($i+1))
    done
}

config_helm