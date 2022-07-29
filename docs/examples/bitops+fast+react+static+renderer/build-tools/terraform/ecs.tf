resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  tags = merge(var.common_tags,{
    Name        = "${var.app_name}-ecs"
  })
}
resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.app_name}-${var.app_environment}-logs"

  tags = merge(var.common_tags,{
    Application = var.app_name
  })
}