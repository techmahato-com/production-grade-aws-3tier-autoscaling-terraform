# =============================================================================
# Root Module — Composes all modules for the 3-Tier Architecture
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Phase 1: Network & Foundation
# -----------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  web_subnet_cidrs    = var.web_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
}

# -----------------------------------------------------------------------------
# Phase 2: Security Configuration
# -----------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

# -----------------------------------------------------------------------------
# Phase 3: Bastion Host
# -----------------------------------------------------------------------------
module "bastion" {
  source = "./modules/bastion"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.bastion_instance_type
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_id     = module.security.bastion_sg_id
  key_pair_name         = var.key_pair_name
  instance_profile_name = module.security.ec2_instance_profile_name
}

# -----------------------------------------------------------------------------
# Phase 4: Load Balancers
# -----------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  web_subnet_ids     = module.vpc.web_subnet_ids
  app_subnet_ids     = module.vpc.app_subnet_ids
  external_alb_sg_id = module.security.external_alb_sg_id
  internal_alb_sg_id = module.security.internal_alb_sg_id
}

# -----------------------------------------------------------------------------
# Phase 5: Auto Scaling Groups (Web + App)
# -----------------------------------------------------------------------------
module "asg" {
  source = "./modules/asg"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  key_pair_name         = var.key_pair_name
  instance_profile_name = module.security.ec2_instance_profile_name

  # Web Tier
  web_subnet_ids       = module.vpc.web_subnet_ids
  web_sg_id            = module.security.web_sg_id
  web_target_group_arn = module.alb.web_target_group_arn
  web_instance_type    = var.web_instance_type
  web_min_size         = var.web_min_size
  web_max_size         = var.web_max_size
  web_desired_capacity = var.web_desired_capacity

  # App Tier
  app_subnet_ids       = module.vpc.app_subnet_ids
  app_sg_id            = module.security.app_sg_id
  app_target_group_arn = module.alb.app_target_group_arn
  app_instance_type    = var.app_instance_type
  app_min_size         = var.app_min_size
  app_max_size         = var.app_max_size
  app_desired_capacity = var.app_desired_capacity

  # Nginx reverse proxy target
  internal_alb_dns = module.alb.internal_alb_dns

  # Scaling thresholds
  scale_out_cpu_threshold = var.scale_out_cpu_threshold
  scale_in_cpu_threshold  = var.scale_in_cpu_threshold
}

# -----------------------------------------------------------------------------
# Phase 6: Database (RDS)
# -----------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  db_subnet_ids        = module.vpc.db_subnet_ids
  db_sg_id             = module.security.db_sg_id
  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_allocated_storage = var.db_allocated_storage
  db_backup_retention  = var.db_backup_retention
}

# -----------------------------------------------------------------------------
# Phase 7: Monitoring & Observability
# -----------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name            = var.project_name
  environment             = var.environment
  web_asg_name            = module.asg.web_asg_name
  app_asg_name            = module.asg.app_asg_name
  db_instance_id          = "${var.project_name}-${var.environment}-mysql"
  external_alb_arn_suffix = module.alb.external_alb_arn
}

# -----------------------------------------------------------------------------
# Phase 8: WAF
# -----------------------------------------------------------------------------
module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  environment  = var.environment
  alb_arn      = module.alb.external_alb_arn
}
