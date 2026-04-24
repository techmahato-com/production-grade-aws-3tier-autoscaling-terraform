# =============================================================================
# Dev Environment Configuration
# =============================================================================

project_name = "ecommerce"
environment  = "dev"
aws_region   = "us-east-1"
owner        = "DevOps-Team"

# Network
vpc_cidr            = "10.2.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
web_subnet_cidrs    = ["10.2.11.0/24", "10.2.12.0/24"]
app_subnet_cidrs    = ["10.2.21.0/24", "10.2.22.0/24"]
db_subnet_cidrs     = ["10.2.31.0/24", "10.2.32.0/24"]

# Bastion
bastion_instance_type = "t3.micro"
allowed_ssh_cidrs     = ["0.0.0.0/0"]   # CHANGE THIS
key_pair_name         = "your-key-pair" # CHANGE THIS

# Web Tier — minimal for dev
web_instance_type    = "t3.micro"
web_min_size         = 1
web_max_size         = 2
web_desired_capacity = 1

# App Tier — minimal for dev
app_instance_type    = "t3.micro"
app_min_size         = 1
app_max_size         = 2
app_desired_capacity = 1

# Database — minimal for dev
db_instance_class    = "db.t3.micro"
db_name              = "javaapp"
db_username          = "admin"
db_allocated_storage = 20
db_backup_retention  = 1

# Scaling
scale_out_cpu_threshold = 70
scale_in_cpu_threshold  = 30
