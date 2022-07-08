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
