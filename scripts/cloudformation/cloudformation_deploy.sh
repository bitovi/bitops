#!/bin/bash
set -e

CFN_TEMPLATE_FILENAME=$1
CFN_PARAMS_FLAG=$2
CFN_TEMPLATE_PARAMS_FILENAME=$3
CFN_STACK_NAME=$4
CFN_CAPABILITY=$5
CFN_TEMPLATE_S3_BUCKET=$6
CFN_S3_PREFIX=$7

CFN_TEMPLATE_PARAM="--template-body=file://$CFN_TEMPLATE_FILENAME"
if [ -n "$CFN_TEMPLATE_S3_BUCKET" ] && [ -n "$CFN_S3_PREFIX" ]; then
  aws s3 sync $CLOUDFORMATION_ROOT s3://$CFN_TEMPLATE_S3_BUCKET/$CFN_S3_PREFIX/
  if [ $? == 0 ]; then
    echo "Upload to S3 successful"
    CFN_TEMPLATE_PARAM="--template-url https://$CFN_TEMPLATE_S3_BUCKET.s3.amazonaws.com/$CFN_S3_PREFIX/$CFN_TEMPLATE_FILENAME"
  else
    echo "Upload to S3 failed"
  fi
fi

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

if [[ "${CFN_PARAMS_FLAG}" == "True" ]] || [[ "${CFN_PARAMS_FLAG}" == "true" ]]; then
    echo "Parameters file exist..."
    CFN_STACK_ID=$(aws cloudformation $ACTION \
    --stack-name $CFN_STACK_NAME \
    --region $AWS_DEFAULT_REGION \
    $CFN_TEMPLATE_PARAM \
    --parameters=file://$CFN_TEMPLATE_PARAMS_FILENAME \
    --capabilities $CFN_CAPABILITY|jq '.Stacks[0].StackId' \
    )
else
    echo "Parameters file doesn't exist..."
    CFN_STACK_ID=$(aws cloudformation $ACTION \
    --stack-name $CFN_STACK_NAME \
    --region $AWS_DEFAULT_REGION \
    $CFN_TEMPLATE_PARAM \
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