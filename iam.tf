data "aws_iam_policy_document" "bucket_antivirus_definitions" {
  statement {
    sid    = "AllowWriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_updater.arn}:*"]
  }

  statement {
    sid    = "AllowS3GetAndPutWithTagging"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
    ]
    resources = ["${aws_s3_bucket.antivirus_definitions.arn}/*"]
  }

  statement {
    sid     = "AllowS3HeadObject"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.antivirus_definitions.arn,
      "${aws_s3_bucket.antivirus_definitions.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "bucket_antivirus_scanner" {
  statement {
    sid    = "AllowWriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_scanner.arn}:*"]
  }

  statement {
    sid    = "AllowS3AVScan"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
    ]
    resources = [for bucket in var.buckets_to_scan : "arn:aws:s3:::${bucket.bucket}/*"]
  }

  statement {
    sid    = "AllowS3AVDefinitions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
    ]
    resources = ["${aws_s3_bucket.antivirus_definitions.arn}/*"]
  }

  statement {
    sid       = "AllowKMSDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [for bucket in var.buckets_to_scan : "arn:aws:s3:::${bucket.bucket}/*"]
  }

  statement {
    sid     = "AllowSNSPublish"
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      "arn:aws:sns:${data.aws_region._.name}:${data.aws_caller_identity._.account_id}:${local.names["sns_scanner_destination_topic"]}",
    ]
  }

  statement {
    sid     = "AllowS3HeadObject"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.antivirus_definitions.arn,
      "${aws_s3_bucket.antivirus_definitions.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    sid     = "AllowLambdaSTSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bucket_antivirus_update" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
    ]
    resources = [
      aws_s3_bucket.antivirus_definitions.arn,
      "${aws_s3_bucket.antivirus_definitions.arn}/*",
    ]
  }
}

resource "aws_iam_role" "antivirus_scanner_role" {
  name               = local.names["iam_scanner_role"]
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_policy" "antivirus_scanner_policy" {
  name        = local.names["iam_scanner_policy"]
  path        = "/"
  description = "Allows antivirus lambda function to scan buckets"
  policy      = data.aws_iam_policy_document.bucket_antivirus_scanner.json
}

resource "aws_iam_role_policy_attachment" "antivirus_scanner_policy" {
  policy_arn = aws_iam_policy.antivirus_scanner_policy.arn
  role       = aws_iam_role.antivirus_scanner_role.name
}

resource "aws_iam_role" "antivirus_update_role" {
  name               = local.names["iam_update_role"]
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_policy" "antivirus_update_policy" {
  name        = local.names["iam_update_policy"]
  path        = "/"
  description = "Allows antivirus lambda function to update its definitions"
  policy      = data.aws_iam_policy_document.bucket_antivirus_update.json
}

resource "aws_iam_role_policy_attachment" "antivirus_update_policy" {
  policy_arn = aws_iam_policy.antivirus_update_policy.arn
  role       = aws_iam_role.antivirus_update_role.name
}
