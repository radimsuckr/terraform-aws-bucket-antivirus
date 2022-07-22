provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "test" {
  bucket_prefix = "av-test"
  force_destroy = true
}

data "aws_iam_policy_document" "deny_getting_and_tagging_infected_objects" {
  statement {
    sid    = "DenyGettingAndTaggingInfectedObjects"
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:PutObjectTagging",
    ]
    resources = ["${aws_s3_bucket.test.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/av-status"
      values   = ["INFECTED"]
    }
  }
}

resource "aws_s3_bucket_policy" "test" {
  bucket = aws_s3_bucket.test.bucket
  policy = data.aws_iam_policy_document.deny_getting_and_tagging_infected_objects.json
}

locals {
  bts = [
    {
      bucket = aws_s3_bucket.test.bucket
      prefixes = [
        "media/a/",
        "media/b/",
        "static/",
      ]
    },
  ]
}

module "antivirus" {
  source = "../../"

  name_prefix = "super-av-module-"

  buckets_to_scan = local.bts
  # scanner_environment_variables = { AV_DELETE_INFECTED_FILES = "True" }
  update_antivirus_definitions_on_deploy = true
  create_sns_scanner_destination_topic   = true
}

module "antivirus_dynamodb_log" {
  source = "../../modules/dynamodb-log-lambda/"

  name_prefix = module.antivirus.name_prefix
  name_suffix = module.antivirus.name_suffix

  sns_scan_result_topic_arn = module.antivirus.sns_scanner_destination_topic

  av_signature_field_name  = module.antivirus.av_signature_field_name
  av_status_field_name     = module.antivirus.av_status_field_name
  av_timestamp_field_name  = module.antivirus.av_timestamp_field_name
  av_scan_start_field_name = module.antivirus.av_scan_start_field_name
}
