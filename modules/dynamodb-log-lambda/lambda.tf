resource "aws_lambda_function" "processor" {
  function_name = local.names["lambda_function"]
  timeout       = 30
  memory_size   = 512
  runtime       = "python3.9"
  handler       = "processor.handler"
  role          = aws_iam_role.processor_role.arn

  s3_bucket = aws_s3_bucket.lambda.bucket
  s3_key    = aws_s3_bucket_object.lambda.key

  source_code_hash = filebase64sha256(local.lambda_source_code)

  layers = (var.sentry_dsn != "" ? ["arn:aws:lambda:${data.aws_region._.name}:943013980633:layer:SentryPythonServerlessSDK:29"] : [])

  environment {
    variables = {
      AV_SIGNATURE_FIELD_NAME  = var.av_signature_field_name
      AV_STATUS_FIELD_NAME     = var.av_status_field_name
      AV_TIMESTAMP_FIELD_NAME  = var.av_timestamp_field_name
      AV_SCAN_START_FIELD_NAME = var.av_timestamp_field_name
      DYNAMODB_TABLE           = aws_dynamodb_table.log.name
      INFECTED_STATUS          = var.infected_status
      SENTRY_DSN               = var.sentry_dsn
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_scan_result_topic_arn
}
