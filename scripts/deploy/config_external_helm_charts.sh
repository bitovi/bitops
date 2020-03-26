#!/usr/bin/env bash

set -e 

function config_external_helm_charts() {
    count=$(shyaml get-value helm < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $(shyaml get-value helm < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l) ]
    do
      HELM_ACTION=$(shyaml get-value helm.actions.$i.enabled < "$TEMPDIR/bitops.config.default.yaml")
      HELM_ACTION_NAME=$(shyaml get-value helm.actions.$i.name < "$TEMPDIR/bitops.config.default.yaml")
      if [ "$HELM_ACTION" == True ]
      then
          if [ $HELM_ACTION_NAME == "external_helm_charts" ]
          then
              URL=$(shyaml get-value helm.actions.$i.url < "$TEMPDIR/bitops.config.default.yaml")
              CHART_NAME=$(shyaml get-value helm.actions.$i.chart_name < "$TEMPDIR/bitops.config.default.yaml")
              EXTERNAL_HELM_CHARTS=$CHART_NAME,$URL
              echo "$EXTERNAL_HELM_CHARTS"
          fi 
      fi
      i=$(($i+1))
    done
}

config_external_helm_charts