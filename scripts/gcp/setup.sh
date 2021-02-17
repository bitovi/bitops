#!/usr/bin/env bash

echo "Verifying..."
bash $SCRIPTS_DIR/aws/validate_env.sh

echo "Decoding service key"
DECODED_GKE_KEY=$(echo ${GKE_KEY} | base64 -d)
echo "Saving service account to file"
echo ${DECODED_GKE_KEY} > ${HOME}/gcloud-service-key.json

echo "Authenticating with GCE"
/usr/local/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file "${HOME}"/gcloud-service-key.json
/usr/local/google-cloud-sdk/bin/gcloud --quiet config set project "$PROJECT_ID"
/usr/local/google-cloud-sdk/bin/gcloud config set project "$PROJECT_ID"
/usr/local/google-cloud-sdk/bin/gcloud config list account --format "value(core.account)"

if [ $? == 0 ]; then 
  echo "Setup GCE Authentication successfully."
  exit 0
else
  echo "GCE Authentication failed." 
  exit 1
fi

if [ "$REGISTRY_HOSTNAME" == 'gcr.io' ]; then
  echo "Setting up Docker to use Google Registry..."
  /usr/local/google-cloud-sdk/bin/gcloud --quiet auth configure-docker
  /usr/local/google-cloud-sdk/bin/gcloud container clusters get-credentials "$CLUSTER" --project "$PROJECT_ID" --region "$REGION"
  /usr/local/google-cloud-sdk/bin/gcloud --quiet auth configure-docker
  if [ $? == 0 ]; then 
    echo "Setup Google Registry successfully."
    exit 0
  else
    echo "Google Registry setup failed." 
    exit 1
  fi
fi


