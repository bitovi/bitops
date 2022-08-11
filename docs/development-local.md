At this point you should have a repo for your custom BitOps image and have it open in your favorite editor. For more information on setting up your [custom BitOps image](custom-image.md)


## Create a plugins.dockerfile
Create a file in the root level of BitOps named `Dockerfile.plugins` with the content; 

`FROM bitovi/bitops:2.0.0`


## Build BitOps (with plugins)
`docker build -t bitops:latest . -f Dockerfile.plugins`


## Run BitOps
```
docker run \
  -e BITOPS_ENVIRONMENT=environment  \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=your-aws-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key \
  -v /path/to/operations_repo:/opt/bitops_deployment \
  bitops:latest
```


# Benefits to local testing
- configuration validation
- rapid testing of new features
- get your hands dirty!
