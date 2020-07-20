#!/usr/bin/env bash

set -e 

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  printf "${ERROR}environment variable (AWS_ACCESS_KEY_ID) not set ${NC}"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  printf "${ERROR}environment variable (AWS_SECRET_ACCESS_KEY) not set ${NC}"
  exit 1
fi
if [ -z "$AWS_DEFAULT_REGION" ]; then
  printf "${ERROR}environment variable (AWS_DEFAULT_REGION) not set ${NC}"
  exit 1
fi
