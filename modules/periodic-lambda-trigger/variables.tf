variable "name" {
  default = null
  type    = string
}

variable "description" {
  default = null
  type    = string
}

variable "input" {
  default = null
  type    = string
}

variable "schedule_expression" {
  type = string
}

variable "lambda_function" {
  type = object({
    arn           = string
    function_name = string
  })
}
