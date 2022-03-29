
#contentful access token
#https://us-west-2.console.aws.amazon.com/secretsmanager/home?region=us-west-2#!/secret?name=ContentfulAccessToken

data "aws_secretsmanager_secret" "contentful_access_token" {
  arn = var.secret_arn_contentful_access_token
}

data "aws_secretsmanager_secret_version" "access_token" {
  secret_id = data.aws_secretsmanager_secret.contentful_access_token.id
}


#contentful space id
#https://us-west-2.console.aws.amazon.com/secretsmanager/home?region=us-west-2#!/secret?name=ContentfulSpaceID

data "aws_secretsmanager_secret" "contentfulspaceid" {
  arn = var.secret_arn_contentful_space_id
}

data "aws_secretsmanager_secret_version" "spaceid" {
  secret_id = data.aws_secretsmanager_secret.contentfulspaceid.id
}


