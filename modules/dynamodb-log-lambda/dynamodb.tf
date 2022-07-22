locals {
  ddb_table_log_hash_key  = "s3_uri"
  ddb_table_log_range_key = "version"
}

resource "aws_dynamodb_table" "log" {
  name         = local.names["dynamodb_table"]
  hash_key     = local.ddb_table_log_hash_key
  range_key    = local.ddb_table_log_range_key
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = local.ddb_table_log_hash_key
    type = "S"
  }

  attribute {
    name = local.ddb_table_log_range_key
    type = "S"
  }
}
