output "definitions_bucket" {
  description = "The bucket created to store de antivirus definitions"
  value       = aws_s3_bucket.antivirus_definitions
}

output "scanner_function" {
  description = "The created scanner function resource"
  value       = aws_lambda_function.antivirus_scanner
}

output "update_function" {
  description = "The created definitions update function resource"
  value       = aws_lambda_function.antivirus_update
}

output "scanner_function_role" {
  description = "The role used by the scanner function"
  value       = aws_iam_role.antivirus_scanner_role
}

output "update_function_role" {
  description = "The role used by the definitions update function"
  value       = aws_iam_role.antivirus_update_role
}

output "scanner_function_policy" {
  description = "The policy attached to the scanner function role"
  value       = aws_iam_policy.antivirus_scanner_policy
}

output "update_function_policy" {
  description = "The policy attached to the definitions update function role"
  value       = aws_iam_policy.antivirus_update_policy
}

output "sns_scanner_destination_topic" {
  description = "ARN of the SNS topic for results of scanned objects"
  value       = var.create_sns_scanner_destination_topic ? aws_sns_topic.scanner_destination[0].arn : null
}

output "av_signature_field_name" {
  description = "Name of the field containing antivirus signature"
  value       = var.av_signature_field_name
}

output "av_status_field_name" {
  description = "Name of the field containing antivirus result"
  value       = var.av_status_field_name
}

output "av_timestamp_field_name" {
  description = "Name of the field containing antivirus timestamp"
  value       = var.av_timestamp_field_name
}

output "av_scan_start_field_name" {
  description = "Name of the field containing antivirus scan start timestamp"
  value       = var.av_scan_start_field_name
}

output "name_prefix" {
  description = "Prefix for all resource names"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Suffix for all resource names"
  value       = var.name_suffix
}
