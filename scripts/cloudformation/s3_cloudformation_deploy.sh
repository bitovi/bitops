#!/bin/bash
set -e

CFN_TEMPLATE_FILENAME=$1
CFN_PARAMS_FLAG=$2
CFN_TEMPLATE_PARAMS_FILENAME=$3
CFN_STACK_NAME=$4
CFN_CAPABILITY=$5
CFN_TEMPLATE_S3_BUCKET=$6
CFN_S3_PREFIX=$7

echo "Checking if stack exists ..."
STACK_EXISTS=$(aws cloudformation describe-stacks --region $AWS_DEFAULT_REGION --stack-name $CFN_STACK_NAME|jq '.Stacks[0].StackId')
if [[ -z $STACK_EXISTS  ]]
then
	ACTION="create-stack"
  echo -e "\nStack does not exist, creating ..."
else
  ACTION="update-stack"
  echo -e "\nStack exists, attempting update ..."
fi

if [ -n "$CFN_TEMPLATE_S3_BUCKET" ] && [ -n "$CFN_S3_PREFIX" ]; then
  aws s3 sync $CLOUDFORMATION_ROOT s3://$CFN_TEMPLATE_S3_BUCKET/$CFN_S3_PREFIX/
  if [ $? == 0 ]; then
    echo "Upload to S3 successful"
  else
    echo "Upload to S3 failed"
  fi

  #Ian - Debug
  echo "S3_URL: https://$CFN_TEMPLATE_S3_BUCKET.amazonaws.com/$CFN_S3_PREFIX/$CFN_TEMPLATE_FILENAME"
  echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"


  if [[ "${CFN_PARAMS_FLAG}" == "True" ]] || [[ "${CFN_PARAMS_FLAG}" == "true" ]]; then
      echo "Parameters file exist..."
      CFN_STACK_ID=$(aws cloudformation $ACTION \
      --stack-name $CFN_STACK_NAME \
      --region $AWS_DEFAULT_REGION \
      --template-url https://$CFN_TEMPLATE_S3_BUCKET.s3.amazonaws.com/$CFN_S3_PREFIX/$CFN_TEMPLATE_FILENAME \
      --parameters=file://$CFN_TEMPLATE_PARAMS_FILENAME \
      --capabilities $CFN_CAPABILITY|jq '.Stacks[0].StackId' \
      )
  else
      echo "Parameters file doesn't exist..."
      CFN_STACK_ID=$(aws cloudformation $ACTION \
      --stack-name $CFN_STACK_NAME \
      --region $AWS_DEFAULT_REGION \
      --template-url https://$CFN_TEMPLATE_S3_BUCKET.s3.amazonaws.com/$CFN_S3_PREFIX/$CFN_TEMPLATE_FILENAME \
      --capabilities $CFN_CAPABILITY|jq '.Stacks[0].StackId' \
      )
  fi

  if [ "$ACTION" == "create-stack" ]; then
    echo "Waiting on cloudformation stack ${CFN_STACK_NAME} $ACTION completion..."
    aws cloudformation wait stack-create-complete --stack-name ${CFN_STACK_NAME}
  else
    echo "Waiting on cloudformation stack ${CFN_STACK_NAME} $ACTION completion..."
    aws cloudformation wait stack-update-complete --stack-name ${CFN_STACK_NAME}
  fi

  aws cloudformation describe-stacks --stack-name ${CFN_STACK_NAME} | jq '.Stacks[0]'
  echo "Finished cloudfromation action $ACTION successfully !!!"
else 
  echo "Please provide s3 bucket name and s3 prefix: ./cf_deploy.sh <CFN_TEMPLATE_FILENAME> <CFN_PARAMS_FLAG> \
  <CFN_TEMPLATE_PARAMS_FILENAME> <CFN_STACK_NAME> <CFN_CAPABILITY> \
  <BUCKET_NAME> <DIRECTORY_NAME> <S3_PREFIX>"
  printenv
  exit 1
fi