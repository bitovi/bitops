# Bitops Operations Repo

This example shows a minimal Terraform configuration that creates an EKS cluster in `test` environment with a shared `_default` dir as an introduction to BitOps v2.0.



See our blog post [Getting started with BitOps v2.0 - Terraform](https://www.bitovi.com/blog/getting-started-with-bitops-v2-terraform) on how this is used

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