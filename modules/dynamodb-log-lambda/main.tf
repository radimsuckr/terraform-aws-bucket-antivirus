locals {
  lambda_source_code = pathexpand("${path.module}/resources/lambda.zip")
  names = {
    dynamodb_table        = "${var.name_prefix}${var.dynamodb_table_name}${var.name_suffix}"
    lambda_function       = "${var.name_prefix}av-infections-processor${var.name_suffix}"
    iam_policy_lambda     = "${var.name_prefix}av-infections-processor${var.name_suffix}"
    iam_role_lambda       = "${var.name_prefix}av-infections-processor${var.name_suffix}"
    s3_lambda_code_bucket = "${var.name_prefix}av-infections-processor-code${var.name_suffix}"
  }
}

data "aws_region" "_" {}
