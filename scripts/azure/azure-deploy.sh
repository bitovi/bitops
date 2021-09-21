#!/usr/bin/env bash

set -e


if [ -n "${AZ_CLIENT_ID}" ] && [ -n "${AZ_CLIENT_SECRET}" ] && [ -n "${AZ_SUBSCRIPTION_ID}" ] && [ -n "${AZ_TENANT_ID}" ]; then
  echo "Required Azure variables found."
else 
  echo "AZ_CLIENT_ID, AZ_CLIENT_SECRET, AZ_SUBSCRIPTION_ID or AZ_TENANT_ID variable not found."
  exit 1
fi

az login --service-principal -u $AZ_CLIENT_ID -p $AZ_PASSWORD --tenant $AZ_TENANT_ID
if [ $? == 0]; then 
  echo "Successfully Authenticated with Azure"
else 
  echo "Authentication Failed"
  exit 1
fi 

