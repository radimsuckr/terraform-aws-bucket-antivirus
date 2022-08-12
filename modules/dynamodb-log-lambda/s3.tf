resource "aws_s3_bucket" "lambda" {
  bucket        = local.names["s3_lambda_code_bucket"]
  force_destroy = true
}

resource "aws_s3_bucket_object" "lambda" {
  bucket = aws_s3_bucket.lambda.bucket
  key    = "lambda.zip"
  source = local.lambda_source_code
}
