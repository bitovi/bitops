#!/usr/bin/env bash

set -e

#Setup kubernetes config and context
mkdir -p ~/.kube
aws eks --region us-east-2 update-kubeconfig --name BitOps --profile default

export PROJECT_ROOT="../.."
export CURRENT_ENVIRONMENT=$(cat ../../config.yml | shyaml get-value environment.default)
printenv

for ENV in `ls $PROJECT_ROOT/charts/`
do
    if [ -z "$CURRENT_ENVIRONMENT" ]; then
        #helm install -n $CURRENT_ENVIRONMENT $chart
        echo "Deploying all environments"
    else
        echo "Deploying $chart in $CURRENT_ENVIRONMENT environment"
        #helm install -n $CURRENT_ENVIRONMENT $PROJECT_ROOT/charts/$ENV
        CHARTS=$(ls $PROJECT_ROOT/charts/$ENV)
        for chart in $CHARTS
        do
          echo $chart
          if [ -e $PROJECT_ROOT/charts/$ENV/$chart/requirements.yaml ]; then
             cd $PROJECT_ROOT/charts/$ENV
             helm install -n $CURRENT_ENVIRONMENT $chart
             ls $chart
             echo "deployed $chart"
          fi
        done
    fi
done
