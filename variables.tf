variable "buckets_to_scan" {
  description = "List of bucket names to be scanned by the antivirus"
  type = list(object({
    bucket   = string
    prefixes = list(string)
  }))
}

variable "scanner_environment_variables" {
  default     = {}
  description = "Custom environment variables for the scanner function"
  type        = map(string)
}

variable "updater_environment_variables" {
  default     = {}
  description = "Custom environment variables for the definitions update function"
  type        = map(string)
}

variable "allow_public_access" {
  default     = false
  description = "If true, contents of the bucket in which the antivirus definitions are saved will be public. Good for sharing the same definitions across multiple accounts."
  type        = bool
}

variable "antivirus_update_rate" {
  default     = "3 hours"
  description = "Configures the antivirus update rate. Syntax is the same of cloudwatch rate schedule expression for rules"
  type        = string
}

variable "create_sns_scanner_destination_topic" {
  default     = false
  description = "Create an SNS topic for notifications from scanner Lambda"
  type        = bool
}

variable "sns_scanner_destination_topic_kms_key" {
  default     = "alias/aws/sns"
  description = "KMS key id to use for SNS scanner destination topic encryption"
  type        = string
}

variable "s3_antivirus_definitions_kms_key" {
  default     = "alias/aws/s3"
  description = "KMS key id to use for S3 antivirus definitions bucket encryption"
  type        = string
}

variable "s3_antivirus_code_kms_key" {
  default     = "alias/aws/s3"
  description = "KMS key id to use for S3 antivirus code bucket encryption"
  type        = string
}

variable "update_antivirus_definitions_on_deploy" {
  default     = true
  description = "Toggle to update antivirus definitions on deploy"
  type        = bool
}

variable "av_signature_field_name" {
  description = "Name of the field containing antivirus signature"
  default     = "av-signature"
  type        = string
}

variable "av_status_field_name" {
  description = "Name of the field containing antivirus result"
  default     = "av-status"
  type        = string
}

variable "av_timestamp_field_name" {
  description = "Name of the field containing antivirus timestamp"
  default     = "av-timestamp"
  type        = string
}

variable "av_scan_start_field_name" {
  description = "Name of the field containing antivirus scan start timestamp"
  default     = "av-scan-start"
  type        = string
}

variable "name_prefix" {
  default     = ""
  description = "Prefix for all resource names"
  type        = string
}

variable "name_suffix" {
  default     = ""
  description = "Suffix for all resource names"
  type        = string
}
