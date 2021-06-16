#!/bin/bash
set -e

CFN_TEMPLATE_FILENAME=$1
CFN_PARAMS_FLAG=$2
CFN_TEMPLATE_PARAMS_FILENAME=$3
CFN_STACK_NAME=$4
CFN_CAPABILITY=$5
CFN_TEMPLATE_S3_BUCKET=$6
CFN_S3_PREFIX=$7
STATUS="UNKNOWN"

CFN_TEMPLATE_PARAM="--template-body=file://$CFN_TEMPLATE_FILENAME"
if [ -n "$CFN_TEMPLATE_S3_BUCKET" ] && [ -n "$CFN_S3_PREFIX" ]; then
  echo "CFN_TEMPLATE_S3_BUCKET is set, syncing operations repo with S3..."
  aws s3 sync $CLOUDFORMATION_ROOT s3://$CFN_TEMPLATE_S3_BUCKET/$CFN_S3_PREFIX/
  if [ $? == 0 ]; then
    echo "Upload to S3 successful..."
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


until echo "$STATUS" | egrep -q 'CREATE_COMPLETE|UPDATE_COMPLETE|COMPLETE|FAILED|DELETE_IN_PROGRESS'; 
do   
  aws cloudformation describe-stack-events --stack-name "${CFN_STACK_NAME}" --query 'StackEvents[?contains(ResourceStatus,`CREATE_IN_PROGRESS`)].[LogicalResourceId, ResourceStatus, ResourceType, ResourceStatusReason]';
  aws cloudformation describe-stack-events --stack-name "${CFN_STACK_NAME}" --query 'StackEvents[?contains(ResourceStatus,`FAILED`)].[LogicalResourceId, ResourceStatus, ResourceType, ResourceStatusReason]';
  sleep 10; 
  STATUS=$(aws cloudformation describe-stacks --stack-name "${CFN_STACK_NAME}" --query "Stacks[0].StackStatus" --output text);
done

# get final status
aws cloudformation describe-stack-events --stack-name "${CFN_STACK_NAME}" --output text --no-paginate;

echo "$STATUS" | egrep -q "CREATE_COMPLETE|UPDATE_COMPLETE"
if [ $? == 0 ]; then
  echo "Finished cloudfromation action $ACTION successfully !!!"
  exit 0
else 
  echo "Failed to perform action $ACTION !!!"
  exit 1
fi