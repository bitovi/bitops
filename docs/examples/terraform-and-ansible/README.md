This example shows how terraform could be used to provision infrastructure and then passed on to ansible for configuration.

To run this example, open a terminal in this directory and run
```
docker run \
-e ENVIRONMENT="test" \
-e AWS_ACCESS_KEY_ID=skip \
-e AWS_SECRET_ACCESS_KEY=skip \
-e AWS_DEFAULT_REGION="us-east-1" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```