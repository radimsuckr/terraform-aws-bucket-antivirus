variable "sns_scan_result_topic_arn" {
  description = "ARN of SNS topic with scan results"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB log table"
  default     = "antivirus-result-log"
  type        = string
}

variable "av_signature_field_name" {
  description = "Name of the field containing antivirus signature"
  type        = string
}

variable "av_status_field_name" {
  description = "Name of the field containing antivirus result"
  type        = string
}

variable "av_timestamp_field_name" {
  description = "Name of the field containing antivirus timestamp"
  type        = string
}

variable "av_scan_start_field_name" {
  description = "Name of the field containing antivirus scan start timestamp"
  type        = string
}

variable "infected_status" {
  description = "Value indicating that an object is infected"
  default     = "INFECTED"
  type        = string
}

variable "sentry_dsn" {
  default = ""
  type    = string
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
