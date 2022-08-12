resource "aws_sns_topic" "scanner_destination" {
  count = var.create_sns_scanner_destination_topic ? 1 : 0

  name = local.names["sns_scanner_destination_topic"]

  kms_master_key_id = var.sns_scanner_destination_topic_kms_key
}
