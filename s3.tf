resource "aws_s3_bucket" "antivirus_definitions" {
  bucket_prefix = "bucket-antivirus-definitions"
  force_destroy = true
}

resource "aws_s3_bucket" "antivirus_code" {
  bucket_prefix = "antivirus-code"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "public_antivirus_definitions" {
  count  = var.allow_public_access == true ? 1 : 0
  bucket = aws_s3_bucket.antivirus_definitions.bucket
  policy = data.aws_iam_policy_document.bucket_antivirus_definitions.json
}
