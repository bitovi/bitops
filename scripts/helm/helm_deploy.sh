#!/bin/bash

export CURRENT_ENVIRONMENT=$(cat config.yml | shyaml get-value environment.default)

helm upgrade --install release-name \
  --namespace default \
  --values ./production.yml


