# =============================================================================
# Outputs
# =============================================================================

# Network
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_ips
}

# Bastion
output "bastion_public_ip" {
  description = "Bastion host public IP — use this for SSH jump"
  value       = module.bastion.bastion_public_ip
}

# Load Balancers
output "external_alb_dns" {
  description = "External ALB DNS name — access your application here"
  value       = module.alb.external_alb_dns
}

output "internal_alb_dns" {
  description = "Internal ALB DNS name"
  value       = module.alb.internal_alb_dns
}

# Database
output "db_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.db_endpoint
}

output "db_secret_arn" {
  description = "ARN of Secrets Manager secret with DB credentials"
  value       = module.rds.db_secret_arn
}

# Monitoring
output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

# SSH Command Helper
output "ssh_to_nginx" {
  description = "SSH command to connect to Nginx instances via Bastion"
  value       = "ssh -i <key.pem> -J ec2-user@${module.bastion.bastion_public_ip} ec2-user@<nginx-private-ip>"
}

output "ssh_to_tomcat" {
  description = "SSH command to connect to Tomcat instances via Bastion"
  value       = "ssh -i <key.pem> -J ec2-user@${module.bastion.bastion_public_ip} ec2-user@<tomcat-private-ip>"
}
