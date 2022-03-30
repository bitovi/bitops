# Secrets Management
A set of scripts to ease secrets management.

## Prerequisites
- AWS CLI (and an AWS account)
- yq (Mac: `brew install yq`)

## Common Environment Variables

These environment variables apply to all scripts

- `AWS_SECRETS_REGION`
  - Description: The AWS region the secret resides in
  - Default: `AWS_DEFAULT_REGION`
- `AWS_SECRETS_OUTPUT`
  - Description: The output format of the underlying AWS commands
  - Default: `yaml`

## Best Practices

### Naming
It is best to name each secret something that is scoped to its use.

To be consistent, the convention should be:
```
${operations repo name}/${operations repo environment}/${operations repo tool}
```

#### Naming for helm
For helm secrets, name the secret according to the full path of the tool.

For example, an ops repo secret for the Grafana deployment in the `dev-tools` environment might be called: `operations-staffing-app/dev-tools/helm/grafana`

## Guide
Let's say you have a tool called `dev/helm/my-deployment`.


### Creating the secret
Create a `.yaml` file locally called `values-secrets.yaml` which contains a subset of the helm chart values for `my-deployment`, and place it next to the same tool's `values.yaml` file.

`operations-staffing-app/dev/helm/my-deployment/values-secrets.yaml`
```
password: foo
```

> **Note:** Files named `values-secrets.yaml` are git ignored and will not be checked in.

Save the secret in AWS:
```
cd /path/to/operations-staffing-app
AWS_SECRETS_REGION="us-west-1" \
AWS_SECRETS_SECRET_NAME="operations-staffing-app/dev/helm/my-deployment" \
AWS_SECRETS_SECRET_DESCRIPTION="Secrets for operations-staffing-app/dev/helm/my-deployment" \
AWS_SECRETS_SECRET_FILE="operations-staffing-app/dev/helm/my-deployment/values-secrets.yaml" \
./_scripts/secrets/aws/save-file.sh
```

### Include the secret in the deployment
Create a before script in the helm chart directory:
`operations-staffing-app/dev/helm/my-deployment/bitops.before-deploy.d/fetch-secrets.sh`
```
#!/bin/bash
set -e

AWS_SECRETS_REGION="us-west-1" \
AWS_SECRETS_SECRET_NAME="operations-staffing-app/dev/helm/my-deployment" \
AWS_SECRETS_SECRET_FILE="$HELM_CHART_DIRECTORY/values-secrets.yaml" \
$ROOT_DIR/_scripts/secrets/aws/get-file.sh
```

> **Note:** Ensure the file is executable with `chmod +x <file>`

BitOps will then see the `values-secrets.yaml` at deploy time and include it into the helm deployment.