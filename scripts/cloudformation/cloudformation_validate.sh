#!/usr/bin/env bash
set -e

CFN_TEMPLATE_FILENAME=$1

aws cloudformation validate-template --template-body file://"$CFN_TEMPLATE_FILENAME" 1>/dev/null
if [[ $? -gt 0 ]]; then
    >&2 echo "{\"error\":\"Cloudformation template $CFN_TEMPLATE_FILENAME file validation failed.Exiting...\"}" 
    exit 1
fi
echo "Cloudformation template $CFN_TEMPLATE_FILENAME file validation completed successfully!!!"