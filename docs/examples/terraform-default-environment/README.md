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
This should prodcue the terraform logs:
```
null_resource.test_resource: Creating...
null_resource.test_resource: Provisioning with 'local-exec'...
null_resource.test_resource (local-exec): Executing: ["/bin/sh" "-c" "echo I am a test terraform resource"]
null_resource.test_resource (local-exec): I am a test terraform resource
null_resource.test_resource: Creation complete after 0s [id=1053230725969363428]
```