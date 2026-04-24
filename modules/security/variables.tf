variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into bastion"
  type        = list(string)
}
