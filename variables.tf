# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the infrastructure (for tagging)"
  type        = string
  default     = "DevOps-Team"
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for web-tier private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for app-tier private subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for database-tier private subnets"
  type        = list(string)
  default     = ["10.0.31.0/24", "10.0.32.0/24"]
}

# -----------------------------------------------------------------------------
# Bastion
# -----------------------------------------------------------------------------
variable "bastion_instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

# -----------------------------------------------------------------------------
# Web Tier (Nginx)
# -----------------------------------------------------------------------------
variable "web_instance_type" {
  description = "EC2 instance type for Nginx web servers"
  type        = string
  default     = "t3.micro"
}

variable "web_min_size" {
  description = "Minimum number of Nginx instances"
  type        = number
  default     = 2
}

variable "web_max_size" {
  description = "Maximum number of Nginx instances"
  type        = number
  default     = 6
}

variable "web_desired_capacity" {
  description = "Desired number of Nginx instances"
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# App Tier (Tomcat)
# -----------------------------------------------------------------------------
variable "app_instance_type" {
  description = "EC2 instance type for Tomcat app servers"
  type        = string
  default     = "t3.micro"
}

variable "app_min_size" {
  description = "Minimum number of Tomcat instances"
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "Maximum number of Tomcat instances"
  type        = number
  default     = 6
}

variable "app_desired_capacity" {
  description = "Desired number of Tomcat instances"
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Database (RDS)
# -----------------------------------------------------------------------------
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "javaapp"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 20
}

variable "db_backup_retention" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

# -----------------------------------------------------------------------------
# Scaling Thresholds
# -----------------------------------------------------------------------------
variable "scale_out_cpu_threshold" {
  description = "CPU utilization percentage to trigger scale out"
  type        = number
  default     = 70
}

variable "scale_in_cpu_threshold" {
  description = "CPU utilization percentage to trigger scale in"
  type        = number
  default     = 30
}

# -----------------------------------------------------------------------------
# Domain (Optional)
# -----------------------------------------------------------------------------
variable "domain_name" {
  description = "Domain name for the application (optional, for ACM certificate)"
  type        = string
  default     = ""
}
