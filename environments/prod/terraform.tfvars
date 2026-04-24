# =============================================================================
# Production Environment Configuration
# =============================================================================

# General
project_name = "ecommerce"
environment  = "prod"
aws_region   = "us-east-1"
owner        = "DevOps-Team"

# Network
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
web_subnet_cidrs    = ["10.0.11.0/24", "10.0.12.0/24"]
app_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]
db_subnet_cidrs     = ["10.0.31.0/24", "10.0.32.0/24"]

# Bastion
bastion_instance_type = "t3.micro"
allowed_ssh_cidrs     = ["0.0.0.0/0"]   # CHANGE THIS to your trusted IP/CIDR
key_pair_name         = "your-key-pair" # CHANGE THIS to your EC2 key pair name

# Web Tier (Nginx)
web_instance_type    = "t3.micro"
web_min_size         = 2
web_max_size         = 6
web_desired_capacity = 2

# App Tier (Tomcat)
app_instance_type    = "t3.micro"
app_min_size         = 2
app_max_size         = 6
app_desired_capacity = 2

# Database
db_instance_class    = "db.t3.medium"
db_name              = "javaapp"
db_username          = "admin"
db_allocated_storage = 20
db_backup_retention  = 7

# Scaling
scale_out_cpu_threshold = 70
scale_in_cpu_threshold  = 30
