provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "test" {
  bucket_prefix = "test-antivirus"
  force_destroy = true
}

module "antivirus" {
  source = "../../"

  antivirus_lambda_code = "/Users/radim/Work/bucket-antivirus-function/build/lambda.zip"
  buckets_to_scan       = [aws_s3_bucket.test.bucket]
  # scanner_environment_variables = { AV_DELETE_INFECTED_FILES = "True" }
}
