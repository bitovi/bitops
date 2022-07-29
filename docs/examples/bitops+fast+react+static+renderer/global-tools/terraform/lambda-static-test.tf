# Get lambda hash from s3
# used for source_code_hash so that the lambda updates even if the pointer to s3 doesn't
data "aws_s3_bucket_object" "lambda_hash" {
  bucket = var.bucket_name_lambda
  key    = "${var.app_subpath_lambda}/${var.app_version_lambda}/sha.txt"
}


# Create the lambda
resource "aws_lambda_function" "build_and_publish_static_test" {
  # filename      = "lambda.zip"
  s3_bucket     = var.bucket_name_lambda
  s3_key        = "${var.app_subpath_lambda}/${var.app_version_lambda}/lambda.zip"
  
  # s3_object_version = foo
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda/build-and-publish.handler"

  timeout = "900"
  # https://github.com/lambci/node-custom-lambda
  layers = [
    "arn:aws:lambda:us-west-2:744348701589:layer:bash:8",
    # from: https://harishkm.in/2020/06/16/run-aws-cli-in-a-lambda-function/
    "arn:aws:lambda:us-west-2:368433847371:layer:serverlessrepo-lambda-layer-awscli:1",
    "arn:aws:lambda:us-west-2:553035198032:layer:nodejs12:41"
  ]

  source_code_hash = data.aws_s3_bucket_object.lambda_hash.body

  # runtime = "nodejs12.x"
  runtime = "python2.7"

  environment {
    variables = {
      # Bucket to publish the built files into
      PUBLISH_S3_BUCKET = var.bucket_name

      # root directory in the bucket (S3_BUCKET/APP_SUBPATH)
      APP_SUBPATH = var.app_subpath

      # version subdirectory in the (S3_BUCKET/APP_SUBPATH/APP_VERSION)
      # This value should be the commit hash of an artifact directory (one that pushes stuff to s3)
      # Get this value from: https://github.com/bitovi/cheetah-static-test/commits/main
      APP_VERSION = var.app_version
    }

  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.build_and_publish_static_test,
    data.aws_s3_bucket_object.lambda_hash
  ]

  # tag with a timestamp for cachebusting
  tags = {
    cachebust_timestamp = timestamp()
  }
}



# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "build_and_publish_static_test" {
  name              = "/aws/lambda/static_test/${var.lambda_function_name}"
  retention_in_days = 14
  tags = var.common_tags
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
        "Sid": "ListObjectsInBucket",
        "Effect": "Allow",
        "Action": ["s3:ListBucket"],
        "Resource": ["arn:aws:s3:::${var.bucket_name}"]
    },
    {
        "Sid": "AllObjectActions",
        "Effect": "Allow",
        "Action": "s3:*Object",
        "Resource": ["arn:aws:s3:::${var.bucket_name}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_lambda_invocation" "build_and_publish_static_test" {
  function_name = aws_lambda_function.build_and_publish_static_test.function_name
  input = <<JSON
{
  "key1": "value1",
  "key2": "value2"
}
JSON
  depends_on = [aws_lambda_function.build_and_publish_static_test]
}

output "aws_lambda_invocation_result" {
  value = data.aws_lambda_invocation.build_and_publish_static_test.result
}