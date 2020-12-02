# Bitops Operations Repo

Welcome to Bitops! This serves as a starting point for deploying your application to the cloud.

This repo can be run as is with
```
docker run \
-e ENVIRONMENT="eks" \
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-e AWS_DEFAULT_REGION="us-east-1" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

For more information, check out official bitops docs https://bitovi.github.io/bitops/