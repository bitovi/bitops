# Examples

For complete code samples see [https://github.com/bitovi/bitops/tree/master/docs/examples](https://github.com/bitovi/bitops/tree/master/docs/examples)

## Docker Run Examples
### Selecting Environment
An environment must always be selected
```
docker run \
-e ENVIRONMENT="test-serviceA" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

### AWS Config
```
docker run \
-e ENVIRONMENT="test-serviceA" \
-e AWS_ACCESS_KEY_ID=<AWS_SECRET_ACCESS_KEY> \
-e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
-e AWS_DEFAULT_REGION="us-east-1" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

### Passing in kubeconfig
```
docker run \
-e ENVIRONMENT="test-serviceA" \
-e AWS_ACCESS_KEY_ID=<AWS_SECRET_ACCESS_KEY> \
-e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
-e AWS_DEFAULT_REGION="us-east-1" \
-e KUBECONFIG_BASE64=$(cat /tmp/my-kubeconfig | base64) \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

### Fetch kubeconfig from eks
If you has a cluster arn of `arn:aws:eks:us-east-1:111122223333:cluster/my-cluster`, you would use the following configuration
```
docker run \
-e ENVIRONMENT="test-serviceA" \
-e AWS_ACCESS_KEY_ID=<AWS_SECRET_ACCESS_KEY> \
-e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
-e AWS_DEFAULT_REGION="us-east-1" \
-e CLUSTER_NAME="my-cluster" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

### Force skip over ansible
If there is a `test-serviceA/ansible/` directory, ansible execution can be skipped with `SKIP_DEPLOY_ANSIBLE`
```
docker run \
-e ENVIRONMENT="test-serviceA" \
-e AWS_ACCESS_KEY_ID=<AWS_SECRET_ACCESS_KEY> \
-e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
-e AWS_DEFAULT_REGION="us-east-1" \
-e SKIP_DEPLOY_ANSIBLE=true \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

### Force call terraform destroy
```
docker run \
-e ENVIRONMENT="test-serviceA" \
-e AWS_ACCESS_KEY_ID=<AWS_SECRET_ACCESS_KEY> \
-e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
-e AWS_DEFAULT_REGION="us-east-1" \
-e TERRAFORM_DESTROY=true \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```
## Links to Bitops Guides & Blogs

### Using Declarative Infrastructure to Deploy an EKS Cluster and Helm Chart
* [Using Declarative Infrastructure to Deploy an EKS Cluster and Helm Chart](https://www.bitovi.com/blog/eks-helm-bitops)

### Bitops and Terraform
* [BitOps + Terraform](https://www.bitovi.com/blog/bitops-terraform)

### Combine Terraform and Ansible to provision and configure a webserver
* [Combine Terraform and Ansible to provision and configure a webserver](https://www.bitovi.com/blog/bitops-terraform-ansible)

### StackStorm Series
1. [DevOps Automation using StackStorm - Getting Started Guide](https://www.bitovi.com/blog/devops-automation-using-stackstorm-getting-started)
2. [DevOps Automation using StackStorm - Deploying with Ansible](https://www.bitovi.com/blog/devops-automation-using-stackstorm-ansible-deployment)
3. [DevOps Automation using StackStorm - Cloud Deployment via BitOps](https://www.bitovi.com/blog/devops-automation-using-stackstorm-bitops-infrastructure)
4. [DevOps Automation using StackStorm: BitOps Secrets Management](https://www.bitovi.com/blog/devops-automation-using-stackstorm-bitops-secrets)
