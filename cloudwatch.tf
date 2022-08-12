// Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_scanner" {
  name              = "/aws/lambda/${local.names["lambda_scanner_function"]}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "lambda_updater" {
  name              = "/aws/lambda/${local.names["lambda_updater_function"]}"
  retention_in_days = 14
}
