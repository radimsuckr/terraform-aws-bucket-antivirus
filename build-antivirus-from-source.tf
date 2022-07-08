resource "aws_s3_bucket_object" "antivirus_code" {
  bucket = aws_s3_bucket.antivirus_code.bucket
  key    = "lambda.zip"
  source = pathexpand(var.antivirus_lambda_code)
}
