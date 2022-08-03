# Bitops Operations Repo

Welcome to Bitops! This serves as a starting point for deploying StackStorm to the cloud.

This repo can be run as is with
```
export AWS_ACCESS_KEY_ID=ABCDEF012345 
export AWS_SECRET_ACCESS_KEY=8BuJW2LIlQaTvInalkq0Xzu5ogcf 
export AWS_DEFAULT_REGION=us-west-1 
export TF_STATE_BUCKET=st2-bitops-bucket 
export ST2_GITHUB_TOKEN=wL/SK5g37dz6GqL07YEXKObR6 
docker run \ 
-e ENVIRONMENT="st2-bitops-test" \ 
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \ 
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \ 
-e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \ 
-e TF_STATE_BUCKET=$TF_STATE_BUCKET \ 
-e ST2_GITHUB_TOKEN=$ST2_GITHUB_TOKEN \ 
-v $(pwd):/opt/bitops_deployment \ 
bitovi/bitops:latest
```

For more information, check out official BitOps docs https://bitovi.github.io/bitops/
