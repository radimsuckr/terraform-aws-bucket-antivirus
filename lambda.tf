resource "aws_lambda_function" "antivirus_scanner" {
  depends_on = [
    aws_lambda_invocation.antivirus_update,
  ]

  function_name = local.names["lambda_scanner_function"]
  timeout       = 300
  memory_size   = 2048
  runtime       = "python3.7"
  handler       = "scan.lambda_handler"
  role          = aws_iam_role.antivirus_scanner_role.arn

  source_code_hash = filebase64sha256(local.antivirus_lambda_code_path)

  s3_bucket = aws_s3_bucket.antivirus_code.bucket
  s3_key    = aws_s3_bucket_object.antivirus_code.key

  environment {
    variables = merge(
      {
        AV_DEFINITION_S3_BUCKET = aws_s3_bucket.antivirus_definitions.bucket
      },
      (var.create_sns_scanner_destination_topic ? { AV_STATUS_SNS_ARN = aws_sns_topic.scanner_destination[0].arn } : {}),
      (var.create_sns_scanner_destination_topic ? { AV_SCAN_START_SNS_ARN = aws_sns_topic.scanner_destination[0].arn } : {}),
      var.scanner_environment_variables,
    )
  }
}

resource "aws_lambda_function_event_invoke_config" "antivirus_scanner_sns_scan_result_topic" {
  count = var.create_sns_scanner_destination_topic ? 1 : 0

  function_name                = aws_lambda_function.antivirus_scanner.function_name
  maximum_event_age_in_seconds = 21600
  maximum_retry_attempts       = 2

  destination_config {
    on_success {
      destination = aws_sns_topic.scanner_destination[0].arn
    }

    on_failure {
      destination = aws_sns_topic.scanner_destination[0].arn
    }
  }
}

resource "aws_lambda_permission" "trigger_by_s3" {
  count = length(var.buckets_to_scan)

  statement_id  = "AllowExecutionFromS3BucketsToScan"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.antivirus_scanner.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.buckets_to_scan[count.index].bucket}"
}

resource "aws_s3_bucket_notification" "staging" {
  count = length(var.buckets_to_scan)

  bucket = var.buckets_to_scan[count.index].bucket

  dynamic "lambda_function" {
    for_each = var.buckets_to_scan[count.index].prefixes

    content {
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = lambda_function.value
      id                  = "av-scan-${lambda_function.value}"
      lambda_function_arn = aws_lambda_function.antivirus_scanner.arn
    }
  }
}

resource "aws_lambda_function" "antivirus_update" {
  function_name = local.names["lambda_updater_function"]
  timeout       = 300
  memory_size   = 1024
  runtime       = "python3.7"
  handler       = "update.lambda_handler"
  role          = aws_iam_role.antivirus_update_role.arn

  s3_bucket = aws_s3_bucket.antivirus_code.bucket
  s3_key    = aws_s3_bucket_object.antivirus_code.key

  source_code_hash = filebase64sha256(local.antivirus_lambda_code_path)

  environment {
    variables = merge(
      {
        AV_DEFINITION_S3_BUCKET = aws_s3_bucket.antivirus_definitions.bucket
      },
      var.updater_environment_variables
    )
  }
}

resource "aws_lambda_invocation" "antivirus_update" {
  count = var.update_antivirus_definitions_on_deploy ? 1 : 0

  function_name = aws_lambda_function.antivirus_update.function_name
  input         = jsonencode({}) // Some body is needed. Empty object it is then.
}

module "trigger_antivirus_update_periodically" {
  source = "./modules/periodic-lambda-trigger"

  lambda_function     = aws_lambda_function.antivirus_update
  schedule_expression = "rate(${var.antivirus_update_rate})"
  description         = "Update antivirus definitions every ${var.antivirus_update_rate}"
}
