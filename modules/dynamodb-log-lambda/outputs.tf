output "dynamodb_table_name" {
  description = "Full name of the DynamoDB table used for logging"
  value       = local.names["dynamodb_table"]
}
