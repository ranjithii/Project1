resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/aws/lambda/app-log-group"
}

resource "aws_cloudwatch_log_stream" "app_log_stream" {
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
  name           = "app-log-stream"
}
