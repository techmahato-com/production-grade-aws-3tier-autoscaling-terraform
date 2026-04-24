variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "web_asg_name" {
  type = string
}

variable "app_asg_name" {
  type = string
}

variable "db_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "external_alb_arn_suffix" {
  type = string
}

variable "sns_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}
