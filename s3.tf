resource "aws_s3_bucket" "antivirus_definitions" {
  bucket        = local.names["s3_antivirus_definitions_bucket"]
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "antivirus_definitions" {
  bucket = aws_s3_bucket.antivirus_definitions.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_antivirus_definitions_kms_key
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "antivirus_code" {
  bucket        = local.names["s3_antivirus_code_bucket"]
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "antivirus_code" {
  bucket = aws_s3_bucket.antivirus_code.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_antivirus_code_kms_key
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "public_antivirus_definitions" {
  count  = var.allow_public_access == true ? 1 : 0
  bucket = aws_s3_bucket.antivirus_definitions.bucket
  policy = data.aws_iam_policy_document.bucket_antivirus_definitions.json
}

resource "aws_s3_bucket_object" "antivirus_code" {
  bucket = aws_s3_bucket.antivirus_code.bucket
  key    = "lambda.zip"
  source = pathexpand(local.antivirus_lambda_code_path)
}
