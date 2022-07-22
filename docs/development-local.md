We assume that at this point you've at the very least cloned the repo locally and have it open in your favorite editor. If you haven't made it there, please take a moment to get yourself set up and comfortable. 


## Build BitOps-base
`docker build -t bitops-base:latest .`

The initial build of BitOps runs through the commands to setup the bitops container environment. At this point it has not installed any plugins, only a short list of utilities and tools that BitOps will directly use. Things such as python3, jq, etc

## Create a plugins.dockerfile
Create a file in the root level of bitops named `Dockerfile.plugins` with the content; 

`FROM bitops-base:latest`


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
