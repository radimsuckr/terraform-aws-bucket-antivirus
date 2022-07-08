resource "aws_lambda_function" "antivirus_scanner" {
  function_name = "bucket-antivirus-scanner"
  timeout       = 300
  memory_size   = 2048
  runtime       = "python3.7"
  handler       = "scan.lambda_handler"
  role          = aws_iam_role.antivirus_scanner_role.arn

  s3_bucket = aws_s3_bucket.antivirus_code.bucket
  s3_key    = aws_s3_bucket_object.antivirus_code.key

  environment {
    variables = merge(
      {
        AV_DEFINITION_S3_BUCKET = aws_s3_bucket.antivirus_definitions.bucket
      },
      var.scanner_environment_variables
    )
  }
}

resource "aws_lambda_permission" "trigger_by_s3" {
  count = length(var.buckets_to_scan)

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.antivirus_scanner.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.buckets_to_scan[count.index]}"
}

resource "aws_s3_bucket_notification" "staging" {
  count  = length(var.buckets_to_scan)
  bucket = var.buckets_to_scan[count.index]

  lambda_function {
    lambda_function_arn = aws_lambda_function.antivirus_scanner.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_function" "antivirus_update" {
  function_name = "bucket-antivirus-update"
  timeout       = 300
  memory_size   = 1024
  runtime       = "python3.7"
  handler       = "update.lambda_handler"
  role          = aws_iam_role.antivirus_update_role.arn

  s3_bucket = aws_s3_bucket.antivirus_code.bucket
  s3_key    = aws_s3_bucket_object.antivirus_code.key

  environment {
    variables = merge(
      {
        AV_DEFINITION_S3_BUCKET = aws_s3_bucket.antivirus_definitions.bucket
      },
      var.updater_environment_variables
    )
  }
}

module "trigger_antivirus_update_periodically" {
  source = "./modules/periodic-lambda-trigger"

  lambda_function     = aws_lambda_function.antivirus_update
  schedule_expression = "rate(${var.antivirus_update_rate})"
  description         = "Update antivirus definitions every ${var.antivirus_update_rate}"
}
