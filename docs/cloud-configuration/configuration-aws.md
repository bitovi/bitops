> ⚠️ Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please check out our [plugin documentation](https://github.com/bitops-plugins/aws).

# AWS

> ⚠️ `bitops.config.yaml` is not yet supported for AWS ([TODO](https://github.com/bitovi/bitops/issues/15)). All configurations must be done with environment variables.

## Configuration

| Item                  | BitOps Property                                    | Environmental Variable | Description                                                  | Default | Required |
| --------------------- | -------------------------------------------------- | ---------------------- | ------------------------------------------------------------ | ------- | -------- |
| aws_access_key_id     | [TODO](https://github.com/bitovi/bitops/issues/15) | AWS_ACCESS_KEY_ID      | Specifies an AWS access key associated with an IAM user or role. See [AWS official documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) | `null`  | Yes      |
| aws_secret_access_key | [TODO](https://github.com/bitovi/bitops/issues/15) | AWS_SECRET_ACCESS_KEY  | Specifies the secret key associated with the access key. This is essentially the "password" for the access key. See [AWS official documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) | `null`  | Yes      |
| aws_default_region    | [TODO](https://github.com/bitovi/bitops/issues/15) | AWS_DEFAULT_REGION     | Specifies the AWS Region to send the request to. See [AWS official documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) | `null`  | Yes      |
| aws_session_token     | [TODO](https://github.com/bitovi/bitops/issues/15) | AWS_SESSION_TOKEN      | Specifies the session token value that is required if you are using temporary security credentials that you retrieved directly from AWS STS operations. See [AWS official documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) | `null`  | No       |

