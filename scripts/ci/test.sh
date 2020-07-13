#!/usr/bin/env bash
set -xe

echo "TODO: add more tests"
exit 0



####
#### TODO: create a new `test.sh` entrypoint to kick of tests
####
docker build -t bitops .
docker run --rm \
--name bitops \
-e CLUSTER_NAME=qa-bitops \
-e KUBECONFIG_BASE64=${KUBECONFIG_BASE64} \
-e AWS_ACCESS_KEY_ID="${BITOPS_AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${BITOPS_AWS_SECRET_ACCESS_KEY}" \
-e AWS_DEFAULT_REGION="${BITOPS_AWS_DEFAULT_REGION}" \
-e TEST=true \
-e ENVIRONMENT=opscruise-test3 \
bitops:latest