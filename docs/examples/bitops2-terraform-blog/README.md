# Bitops Operations Repo

Welcome to Bitops! This serves as a starting point for deploying your application to the cloud.

This repo can be run as is with
```
docker run --rm \
-e BITOPS_ENVIRONMENT="test" \
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-e AWS_DEFAULT_REGION="us-east-2" \
-v $(pwd):/opt/bitops_deployment \
--pull always \
bitovi/bitops:2.0.0
```

For more information, check out official BitOps docs https://bitovi.github.io/bitops/