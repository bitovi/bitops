#!/usr/bin/env bash

set -e

#Setup kubernetes config and context
mkdir -p ~/.kube
#aws eks --region us-east-2 update-kubeconfig --name BitOps --profile default

export PROJECT_ROOT="../.."
export CURRENT_ENVIRONMENT=$(cat ../../config.yml | shyaml get-value environment.default)

if [ -z "$CURRENT_ENVIRONMENT" ]; then
    echo "Deploying all environments"
    for env in qa prod
    do
        echo "$env"
        CHARTS=$(ls $PROJECT_ROOT/$env)
        for chart in $CHARTS
        do
          echo $chart
          if [ -e $PROJECT_ROOT/$env/$chart/requirements.yaml ]; then
            cd $PROJECT_ROOT/$env

            # TODO: Add helm update fuctionality

            helm install -n $env $chart --generate-name
            ls $chart
            echo "deployed $chart"
          else
            "Can't find requirements.yaml at: $PROJECT_ROOT/$env/$chart/requirements.yaml"
          fi
      done
    done
else
    CHARTS=$(ls $PROJECT_ROOT/$CURRENT_ENVIRONMENT)
    for chart in $CHARTS
    do
      echo $chart
      echo "Deploying $chart in $CURRENT_ENVIRONMENT environment"
      helm install -n $CURRENT_ENVIRONMENT $PROJECT_ROOT/$CURRENT_ENVIRONMENT
      if [ -e $PROJECT_ROOT/$CURRENT_ENVIRONMENT/$chart/requirements.yaml ]; then
          cd $PROJECT_ROOT/$CURRENT_ENVIRONMENT
          helm install -n $CURRENT_ENVIRONMENT $chart --generate-name
          ls $chart
          echo "deployed $chart"
      else
          "Can't find requirements.yaml at: $PROJECT_ROOT/$env/$chart/requirements.yaml"
      fi
    done
fi

