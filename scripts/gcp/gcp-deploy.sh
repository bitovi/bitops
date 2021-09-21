#!/usr/bin/env bash

set -e

if [ -n "${GOOGLE_AUTHENTICATION_KEY}" ]; then 
  echo "GOOGLE_AUTHENTICATION_KEY variable found."
else 
  echo "GOOGLE_AUTHENTICATION_KEY variable not found."
  exit 1
fi

if [ -e "${GOOGLE_AUTHENTICATION_KEY}" ]; then 
  echo "Found Google Key"
else 
  echo "Google Key Not Found"
  exit 1
fi