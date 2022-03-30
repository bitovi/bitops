#IAM USER Config

resource "aws_iam_user" "this" {
  name                          = "ci-user"
  path                          = "/cheetah/"
  force_destroy                 = true
  tags = {
    OperationsRepo = "bitovi/operations-cheetah"
    OperationsRepoEnvironment = "global-tools"
  }
}

resource "aws_iam_access_key" "v0" {
  user    = aws_iam_user.this.name
}



#policy
resource "aws_iam_policy" "s3" {
  name        = "ci-user-s3"
  description = "policy for s3"

  
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect":"Allow",
            "Action":[
                "s3:ListBucket"
            ],
            "Resource":"arn:aws:s3:::bitovi-operations-cheetah-sites"
        },
        {
            "Effect":"Allow",
            "Action": "s3:*Object",
            "Resource":"arn:aws:s3:::bitovi-operations-cheetah-sites/*"
        },
        {
            "Effect":"Allow",
            "Action":[
                "s3:ListBucket"
            ],
            "Resource":"arn:aws:s3:::bitovi-operations-cheetah-lambda"
        },
        {
            "Effect":"Allow",
            "Action": "s3:*Object",
            "Resource":"arn:aws:s3:::bitovi-operations-cheetah-lambda/*"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetRegistryPolicy",
                "ecr:DescribeRegistry",
                "ecr:DescribePullThroughCacheRules",
                "ecr:GetAuthorizationToken",
                "ecr:PutRegistryScanningConfiguration",
                "ecr:DeleteRegistryPolicy",
                "ecr:CreatePullThroughCacheRule",
                "ecr:DeletePullThroughCacheRule",
                "ecr:PutRegistryPolicy",
                "ecr:GetRegistryScanningConfiguration",
                "ecr:PutReplicationConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "arn:aws:ecr:*:368433847371:repository/*"
        }
        
    ]
}
EOF
}


resource "aws_iam_policy" "secrets" {
  name        = "iam-ci-user-policy"
  description = "iam-ci-user-policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetRandomPassword",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "secretsmanager:*",
            "Resource": "arn:aws:secretsmanager:*:368433847371:secret:*"
        }
    ]
}
EOF
}



resource "aws_iam_user_policy_attachment" "secrets-attach" {
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.secrets.arn
}


resource "aws_iam_user_policy_attachment" "s3-attach" {
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.s3.arn
}

output "iam_user" {
    value = aws_iam_user.this.name
}
output "iam_user_arn" {
    value = aws_iam_user.this.arn
}


output "secret_access_key" {
    value = aws_iam_access_key.v0.secret
}

output "user_arn" {
    value = aws_iam_user.this.unique_id
}