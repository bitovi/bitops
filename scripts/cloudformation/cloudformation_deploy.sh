#!/bin/bash
set -ex

CFN_TEMPLATE_FILENAME=$1
CFN_PARAMS_FLAG=$2
CFN_TEMPLATE_PARAMS_FILENAME=$3
CFN_STACK_NAME=$4
CFN_CAPABILITY=$5

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
    --template-body=file://$CFN_TEMPLATE_FILENAME \
    --parameters=file://$CFN_TEMPLATE_PARAMS_FILENAME \
    --capabilities $CFN_CAPABILITY|jq '.Stacks[0].StackId' \
    )
else
    echo "Parameters file doesn't exist..."
    CFN_STACK_ID=$(aws cloudformation $ACTION \
    --stack-name $CFN_STACK_NAME \
    --region $AWS_DEFAULT_REGION \
    --template-body=file://$CFN_TEMPLATE_FILENAME \
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