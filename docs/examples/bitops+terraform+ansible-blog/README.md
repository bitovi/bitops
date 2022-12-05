# Bitops Operations Repo for WebServer deployment

This repo is based on the HOWTO blog post [Combine Terraform and Ansible to Provision and Configure a Web Server](https://www.bitovi.com/blog/bitops-terraform-ansible)

This deployment can be run with:
```
docker run \
-e BITOPS_ENVIRONMENT="test" \
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-e AWS_DEFAULT_REGION="us-east-2" \
-e TF_STATE_BUCKET="ansible_terraform_blog" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

For more information, check out official BitOps docs https://bitovi.github.io/bitops/
