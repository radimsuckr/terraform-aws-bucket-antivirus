resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.names["lambda_function"]}"
  retention_in_days = 14
}
