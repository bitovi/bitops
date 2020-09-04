#!/bin/bash
set -e

CFN_STACK_NAME=$1

echo "Checking if stack exists ..."
CFN_STACK_ID=$(aws cloudformation describe-stacks --region $AWS_DEFAULT_REGION --stack-name $CFN_STACK_NAME|jq '.Stacks[0].StackId')
if [[ -z $CFN_STACK_ID  ]]
then
  >&2 echo "{\"error\":\"CFN_STACK_NAME does not exist.Exiting...\"}"
  exit 0
else
  ACTION="delete-stack"
  echo -e "\nStack exists, attempting delete ..."
  aws cloudformation $ACTION --region $AWS_DEFAULT_REGION --stack-name $CFN_STACK_NAME
fi

echo "Waiting on cloudformation $ACTION completion..."
aws cloudformation wait stack-delete-complete --stack-name $CFN_STACK_NAME

cho "Checking if cloudformation stack $CFN_STACK_NAME still exists..."
aws cloudformation describe-stacks --stack-name $CFN_STACK_NAME | jq '.Stacks[0]'
echo "Finished cloudfromation $ACTION action successfully !!!"