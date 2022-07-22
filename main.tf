locals {
  antivirus_lambda_code_path = "${path.module}/resources/lambda.zip"
  names = {
    iam_scanner_policy              = "${var.name_prefix}av-scanner${var.name_suffix}"
    iam_scanner_role                = "${var.name_prefix}av-scanner${var.name_suffix}"
    iam_update_policy               = "${var.name_prefix}av-update${var.name_suffix}"
    iam_update_role                 = "${var.name_prefix}av-update${var.name_suffix}"
    lambda_scanner_function         = "${var.name_prefix}av-scanner${var.name_suffix}"
    lambda_updater_function         = "${var.name_prefix}av-updater${var.name_suffix}"
    s3_antivirus_code_bucket        = "${var.name_prefix}av-code${var.name_suffix}"
    s3_antivirus_definitions_bucket = "${var.name_prefix}av-definitions${var.name_suffix}"
    sns_scanner_destination_topic   = "${var.name_prefix}av-scanner${var.name_suffix}"
  }
}

data "aws_caller_identity" "_" {}

data "aws_region" "_" {}
