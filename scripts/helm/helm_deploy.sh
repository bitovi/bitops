#!/usr/bin/env bash

set -ex

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export PATH=/root/.local/bin:$PATH

ls /opt/deploy/qa

mkdir -p ~/.kube
/root/.local/bin/aws sts get-caller-identity
/root/.local/bin/aws eks update-kubeconfig --name BitOps 
cd scripts/helm/

export PROJECT_ROOT="/opt/deploy"
export CURRENT_ENVIRONMENT=$(cat /opt/deploy/config.yml | shyaml get-value environment.default)

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

            helm install $chart --generate-name
            ls $chart
            echo "deployed $chart"
          else
            "Can't find requirements.yaml at: $PROJECT_ROOT/$env/$chart/requirements.yaml"
          fi
      done
    done
else
    echo "location: $PROJECT_ROOT/$CURRENT_ENVIRONMENT"

    CHARTS=$(ls $PROJECT_ROOT/$CURRENT_ENVIRONMENT)
    for chart in $CHARTS
    do
      echo $chart
      echo "Deploying $chart in $CURRENT_ENVIRONMENT environment"
      if [ -e $PROJECT_ROOT/$CURRENT_ENVIRONMENT/$chart/requirements.yaml ]; then
          cd $PROJECT_ROOT/$CURRENT_ENVIRONMENT
          kubectl config current-context
          helm install $chart --generate-name
          echo "deployed $chart"
      else
          "Can't find requirements.yaml at: $PROJECT_ROOT/$env/$chart/requirements.yaml"
      fi
    done
fi

