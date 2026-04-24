variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

# Web Tier
variable "web_subnet_ids" {
  type = list(string)
}

variable "web_sg_id" {
  type = string
}

variable "web_target_group_arn" {
  type = string
}

variable "web_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "web_min_size" {
  type    = number
  default = 2
}

variable "web_max_size" {
  type    = number
  default = 6
}

variable "web_desired_capacity" {
  type    = number
  default = 2
}

# App Tier
variable "app_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "app_target_group_arn" {
  type = string
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_min_size" {
  type    = number
  default = 2
}

variable "app_max_size" {
  type    = number
  default = 6
}

variable "app_desired_capacity" {
  type    = number
  default = 2
}

# Common
variable "key_pair_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "internal_alb_dns" {
  description = "DNS name of the internal ALB for Nginx reverse proxy config"
  type        = string
}

variable "scale_out_cpu_threshold" {
  type    = number
  default = 70
}

variable "scale_in_cpu_threshold" {
  type    = number
  default = 30
}
