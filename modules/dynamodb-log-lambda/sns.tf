resource "aws_sns_topic_subscription" "user_updates_lambda_target" {
  topic_arn = var.sns_scan_result_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.processor.arn

  filter_policy = jsonencode({
    "${var.av_status_field_name}" : [var.infected_status],
  })
}
