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

We should see logs showing the before and after scripts running
```
+ /bin/bash -x /tmp/tmp.4jcNkVb3sN/test/terraform/bitops.before-deploy.d/my-before-script.sh
I am a before terraform lifecycle script!
+ set -x
+ echo 'I am a before terraform lifecycle script!'
null_resource.test_resource: Creating...
null_resource.test_resource: Provisioning with 'local-exec'...
null_resource.test_resource (local-exec): Executing: ["/bin/sh" "-c" "echo I am a test terraform resource"]
null_resource.test_resource (local-exec): I am a test terraform resource
null_resource.test_resource: Creation complete after 0s [id=8496749575343682584]
...
+ /bin/bash -x /tmp/tmp.4jcNkVb3sN/test/terraform/bitops.after-deploy.d/my-after-script.sh
+ set -x
+ echo 'I am a after terraform lifecycle script!'
I am a after terraform lifecycle script!
```