# TODO: move to its own ops repo env
resource "aws_ecs_task_definition" "build_task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${var.image_registry_url}/${var.image_registry_image}:${var.image_registry_tag}",
      "entryPoint": [],
      "environment": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.app_name}-${var.app_environment}"
        }
      },
      "cpu": 2048,
      "memory": 4096,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "4096"
  cpu                      = "2048"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = merge(var.common_tags,{
    Name        = "${var.app_name}-ecs-td"
  })
}




locals {
  task_overrides_react = jsonencode({
    "containerOverrides": [{
      "name": "${var.app_name}-${var.app_environment}-container",
      "environment": [{
        "name": "APP_VERSION",
        "value": "${var.app_version_react}"
      },{
        "name": "CONTENTFUL_SPACE_ID",
        "value": data.aws_secretsmanager_secret_version.spaceid.secret_string
      },{
        "name": "CONTENTFUL_ACCESS_TOKEN",
        "value": data.aws_secretsmanager_secret_version.access_token.secret_string
      },{
        "name": "APP_SUBPATH",
        "value": "${var.app_subpath_react}"
      },{
        "name": "S3_BUCKET_CONTENTS",
        "value": "${var.s3_bucket_contents_react}"
      },{
        "name": "APP_SUBPATH_PUBLISH_SUFFIX",
        "value": "${var.app_subpath_publish_suffix_react}"
      },{
        "name": "PUBLISH_S3_BUCKET",
        "value": "${var.publish_s3_bucket_react}"
      },{
        "name": "BUILD_OUTPUT_SUBDIRECTORY",
        "value": "${var.build_output_subdirectory_react}"
      },{
        "name": "CLOUDFRONT_DISTRIBUTION_ID",
        "value": "${var.cloudfront_distribution_id_react}"
      }]
    }]
  })
  tags_react = jsonencode([{
      "key": "app-framework",
      "value": "react"
    }]
  )

  task_overrides_angular = jsonencode({
    "containerOverrides": [{
      "name": "${var.app_name}-${var.app_environment}-container",
      "environment": [{
        "name": "APP_VERSION",
        "value": "${var.app_version_angular}"
      },{
        "name": "CONTENTFUL_SPACE_ID",
        "value": data.aws_secretsmanager_secret_version.spaceid.secret_string
      },{
        "name": "CONTENTFUL_ACCESS_TOKEN",
        "value": data.aws_secretsmanager_secret_version.access_token.secret_string
      },{
        "name": "APP_SUBPATH",
        "value": "${var.app_subpath_angular}"
      },{
        "name": "S3_BUCKET_CONTENTS",
        "value": "${var.s3_bucket_contents_angular}"
      },{
        "name": "APP_SUBPATH_PUBLISH_SUFFIX",
        "value": "${var.app_subpath_publish_suffix_angular}"
      },{
        "name": "PUBLISH_S3_BUCKET",
        "value": "${var.publish_s3_bucket_angular}"
      },{
        "name": "BUILD_OUTPUT_SUBDIRECTORY",
        "value": "${var.build_output_subdirectory_angular}"
      },{
        "name": "CLOUDFRONT_DISTRIBUTION_ID",
        "value": "${var.cloudfront_distribution_id_angular}"
      },{
        "name": "INCLUDE_PUPPETEER_LAUNCH_OPTIONS",
        "value": "1"
      }]
    }]
  })
  tags_angular = jsonencode([{
      "key": "app-framework",
      "value": "angular"
    }]
  )

  network_configuration = jsonencode({
    "awsvpcConfiguration": {
      "subnets": aws_subnet.public.*.id,
      "assignPublicIp": "ENABLED"
    }
  })
}

resource "null_resource" "run-build-task-react" {
  depends_on = [
    aws_ecs_task_definition.build_task
  ]


  # run the task
  provisioner "local-exec" {
    command = <<EOF
    aws ecs run-task \
    --cluster="${aws_ecs_cluster.aws-ecs-cluster.name}" \
    --task-definition="${aws_ecs_task_definition.build_task.family}" \
    --launch-type="FARGATE" \
    --network-configuration='${local.network_configuration}' \
    --overrides='${local.task_overrides_react}' \
    --tags='${local.tags_react}'

EOF
  }

  # tag with a timestamp for cachebusting
  triggers = {
    always_run = timestamp()
  }  
}

resource "null_resource" "run-build-task-angular" {
  depends_on = [
    aws_ecs_task_definition.build_task
  ]


  # run the task
  provisioner "local-exec" {
    command = <<EOF
    aws ecs run-task \
    --cluster="${aws_ecs_cluster.aws-ecs-cluster.name}" \
    --task-definition="${aws_ecs_task_definition.build_task.family}" \
    --launch-type="FARGATE" \
    --network-configuration='${local.network_configuration}' \
    --overrides='${local.task_overrides_angular}' \
    --tags='${local.tags_angular}'

EOF
  }

  # tag with a timestamp for cachebusting
  triggers = {
    always_run = timestamp()
  }  
}

