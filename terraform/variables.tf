variable "aws_region" {
  default = "eu-west-1"
}

variable "service_name" {
  type = string
  default = "podmax_service"
}

variable "stage" {
  type = string
  default = "dev"
}

variable "log_retention_in_days" {
  type    = number
  default = 30
}

variable "log_level" {
  type    = string
  default = "info"
}