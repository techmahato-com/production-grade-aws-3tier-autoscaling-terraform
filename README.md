# 🏗️ Production-Grade AWS 3-Tier Architecture with Auto Scaling — Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Arbind%20Mahato-0A66C2?logo=linkedin)](https://www.linkedin.com/in/arbindmahato/)

> Enterprise-grade, fully automated AWS infrastructure for deploying a Java-based web application using a secure, scalable, and highly available 3-tier architecture — provisioned entirely with Terraform.

---

## 📐 Architecture Overview

<p align="center">
  <img src="docs/network-giagram.png" alt="AWS 3-Tier Architecture Diagram" width="100%"/>
</p>

### Three Tiers

| Tier | Component | Subnet | Scaling |
|------|-----------|--------|---------|
| **Presentation** | Nginx Web Servers | Private | Auto Scaling Group (2–6 instances) |
| **Application** | Apache Tomcat (Java/Spring Boot) | Private | Auto Scaling Group (2–6 instances) |
| **Data** | Amazon RDS MySQL (Multi-AZ) | Private (Isolated) | Vertical + Read Replicas |

### Access & Management

| Component | Subnet | Purpose |
|-----------|--------|---------|
| **Bastion Host** | Public | SSH jump box to access all private-tier instances |
| **External ALB** | Public | Internet-facing load balancer routing traffic to Nginx |
| **NAT Gateway** | Public | Outbound internet access for private subnets |

---

## 🚀 Key Features

- **High Availability** — Multi-AZ deployment across `us-east-1a` and `us-east-1b` with automated failover
- **Auto Scaling** — Dynamic scaling policies based on CPU utilization for both web and app tiers
- **Bastion Host Access** — Secure SSH access to private instances via a hardened bastion host in the public subnet
- **Defense-in-Depth Security** — Security Groups, NACLs, IAM least-privilege roles, VPC Flow Logs, WAF, and encryption
- **Infrastructure as Code** — 100% Terraform-managed, modular, reusable, and version-controlled
- **CI/CD Ready** — Integrated with SonarQube (code quality) and JFrog Artifactory (artifact management)
- **Observability** — CloudWatch metrics, alarms, custom memory metrics, and centralized log aggregation
- **Cost Optimized** — Right-sized instances (`t3.micro`), scheduled scaling, and efficient resource utilization

---

## 🗂️ Project Structure

```
production-grade-aws-3tier-autoscaling-terraform/
├── modules/
│   ├── vpc/                    # VPC, Subnets, IGW, NAT, Route Tables
│   ├── security/               # Security Groups, NACLs, IAM Roles
│   ├── bastion/                # Bastion Host in Public Subnet
│   ├── alb/                    # Application Load Balancers (External + Internal)
│   ├── asg/                    # Launch Templates, Auto Scaling Groups
│   ├── rds/                    # RDS MySQL Multi-AZ, Subnet Groups
│   ├── monitoring/             # CloudWatch Dashboards, Alarms, Log Groups
│   └── waf/                    # AWS WAF Rules and Web ACL
├── environments/
│   ├── dev/                    # Dev environment tfvars
│   ├── staging/                # Staging environment tfvars
│   └── prod/                   # Production environment tfvars
├── scripts/
│   ├── userdata-nginx.sh       # Nginx bootstrap script
│   ├── userdata-tomcat.sh      # Tomcat bootstrap script
│   └── memory-metrics.sh       # Custom CloudWatch metric script
├── docs/                       # SOW, architecture diagrams, references
├── main.tf                     # Root module composition
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── providers.tf                # AWS provider configuration
├── backend.tf                  # S3 + DynamoDB remote state
├── terraform.tfvars            # Default variable values
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🛠️ Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Terraform](https://www.terraform.io/downloads) | >= 1.5 | Infrastructure provisioning |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | v2 | AWS authentication & interaction |
| [Git](https://git-scm.com/) | Latest | Version control |
| AWS Account | — | With IAM user having programmatic access |

### AWS Credentials Setup

```bash
aws configure
# AWS Access Key ID: <your-access-key>
# AWS Secret Access Key: <your-secret-key>
# Default region: us-east-1
# Default output format: json
```

---

## ⚡ Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/arbindmahato/production-grade-aws-3tier-autoscaling-terraform.git
cd production-grade-aws-3tier-autoscaling-terraform

# 2. Initialize Terraform
terraform init

# 3. Review the execution plan
terraform plan -var-file=environments/prod/terraform.tfvars

# 4. Apply the infrastructure
terraform apply -var-file=environments/prod/terraform.tfvars

# 5. SSH into private instances via Bastion
ssh -i <key.pem> -J ec2-user@<bastion-public-ip> ec2-user@<private-instance-ip>

# 6. Destroy when done (careful in production!)
terraform destroy -var-file=environments/prod/terraform.tfvars
```

---

## 📦 Implementation Phases

### Phase 1 — Network & Foundation
- VPC with CIDR `10.0.0.0/16`
- 8 Subnets across 2 AZs:
  - 2 Public subnets (Bastion Host, NAT Gateway, External ALB)
  - 2 Private subnets — Web tier (Nginx)
  - 2 Private subnets — App tier (Tomcat)
  - 2 Private subnets — Data tier (RDS)
- Internet Gateway + NAT Gateway (per AZ for HA)
- Route tables with proper associations

### Phase 2 — Security Configuration
- **Security Groups**:
  - Bastion SG: SSH (22) from trusted IPs only
  - Web tier SG: HTTP (80) from External ALB SG only, SSH (22) from Bastion SG only
  - App tier SG: Port 8080 from Web SG only, SSH (22) from Bastion SG only
  - Data tier SG: Port 3306 from App SG only
- **NACLs**: Stateless firewall rules per subnet tier
- **IAM Roles**: EC2 instance profiles with least-privilege policies for CloudWatch, S3, and SSM

### Phase 3 — Bastion Host Deployment
- EC2 instance (`t3.micro`) in public subnet
- Hardened with minimal packages and SSH key-based auth only
- Security Group restricted to specific trusted CIDR ranges
- Acts as SSH jump box to all private-tier instances (Nginx, Tomcat)

### Phase 4 — Database Deployment
- RDS MySQL `db.t3.medium` in Multi-AZ
- Private DB subnet group (no public access)
- Automated backups (7-day retention) with point-in-time recovery
- Encryption at rest (AWS KMS)

### Phase 5 — Application Deployment
- **Tomcat**: Java 11, Spring Boot app served on port 8080 via systemd service (private subnet)
- **Nginx**: Reverse proxy in private subnet, forwarding traffic to internal ALB → Tomcat backend
- User data scripts for automated bootstrapping
- All instances accessible only via Bastion Host

### Phase 6 — Load Balancing & Auto Scaling
- **External ALB**: Internet-facing (public subnet), routes HTTP/HTTPS to Nginx target group (private subnet)
- **Internal ALB**: Routes traffic from Nginx to Tomcat target group (private subnet)
- **ASG Policies**: Scale out at 70% CPU, scale in at 30% CPU
- Health checks: ELB-based with 300s grace period

### Phase 7 — CI/CD Integration
- Git-based source control
- SonarQube for static code analysis
- JFrog Artifactory for Maven artifact storage
- Pipeline-ready architecture for Jenkins/GitHub Actions

### Phase 8 — Monitoring & Observability
- CloudWatch Alarms: CPU, memory, disk, HTTP 5xx errors
- Custom metrics via CloudWatch Agent (memory, swap usage)
- Centralized logging: Tomcat `catalina.out` → CloudWatch Log Groups
- CloudWatch Dashboard for real-time visibility

### Phase 9 — Security & Compliance
- Encryption at rest (EBS, RDS, S3) and in transit (TLS/SSL)
- AWS WAF with rate-limiting and SQL injection protection
- VPC Flow Logs enabled for network audit
- AWS Shield Standard for DDoS protection

---

## 🔐 Security Architecture

```
Internet → WAF → External ALB (HTTPS/TLS) ──→ Nginx (Private Subnet)
                                                    │
                                              [SG: Allow 8080 from Web SG only]
                                                    │
                                              Internal ALB → Tomcat (Private Subnet)
                                                    │
                                              [SG: Allow 3306 from App SG only]
                                                    │
                                              RDS MySQL (Isolated Private Subnet)
                                              [Encrypted at rest + in transit]

SSH Access Path:
  Admin → Bastion Host (Public Subnet) ──SSH──→ Nginx / Tomcat (Private Subnets)
          [SG: SSH from trusted IPs only]        [SG: SSH from Bastion SG only]
```

- SSH access to private instances **only through Bastion Host** — no direct internet access
- Bastion Host locked down to specific trusted IP ranges
- Secrets managed via **AWS Secrets Manager** (DB credentials, API keys)
- **VPC Flow Logs** → S3/CloudWatch for network forensics
- **GuardDuty** enabled for threat detection

---

## 📊 Estimated Monthly Cost

| Resource | Specification | Est. Cost (USD) |
|----------|--------------|-----------------|
| EC2 (Bastion Host) | 1× t3.micro | ~$8 |
| EC2 (Nginx ASG) | 2× t3.micro | ~$15 |
| EC2 (Tomcat ASG) | 2× t3.micro | ~$15 |
| ALB (External + Internal) | 2× ALB | ~$35 |
| RDS MySQL | db.t3.medium, Multi-AZ | ~$70 |
| NAT Gateway | 2× (per AZ) | ~$65 |
| CloudWatch | Metrics + Logs | ~$10 |
| S3 (State + Logs) | Minimal storage | ~$2 |
| **Total** | | **~$220/month** |

> 💡 Use [AWS Pricing Calculator](https://calculator.aws/) for precise estimates based on your workload.

---

## 🧪 Validation & Testing

```bash
# Verify Terraform configuration
terraform validate

# Format check
terraform fmt -check -recursive

# Security scan with tfsec
tfsec .

# Cost estimation with Infracost
infracost breakdown --path .

# After deployment — test ALB endpoint
curl -I http://$(terraform output -raw alb_dns_name)

# SSH into Nginx via Bastion
ssh -i <key.pem> -J ec2-user@<bastion-ip> ec2-user@<nginx-private-ip>

# SSH into Tomcat via Bastion
ssh -i <key.pem> -J ec2-user@<bastion-ip> ec2-user@<tomcat-private-ip>
```

---

## 🔧 Troubleshooting

| Issue | Command | Resolution |
|-------|---------|------------|
| Can't SSH to private instance | `ssh -i key.pem -J ec2-user@<bastion-ip> ec2-user@<private-ip>` | Verify Bastion SG allows SSH from your IP, private SG allows SSH from Bastion SG |
| DB connectivity | `telnet <rds-endpoint> 3306` | Check app-tier SG allows 3306 from app SG |
| ALB health check failing | `aws elbv2 describe-target-health --target-group-arn <arn>` | Verify Nginx/Tomcat is running and SG allows ALB health checks |
| ASG not scaling | `aws autoscaling describe-scaling-activities --auto-scaling-group-name <name>` | Check scaling policy thresholds and cooldown |
| High CPU on Tomcat | `top -bn1` / `ps -eLf \| grep java \| wc -l` | Review JVM heap settings, check for thread leaks |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 👨‍💻 About Me

Hi, I'm **Arbind Mahato** — Senior Cloud & DevOps Engineer specializing in **AWS**, **Kubernetes**, and **DevSecOps**.

I share real-world DevOps projects, tutorials, and cloud architecture insights to help engineers grow in their careers.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Arbind%20Mahato-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/arbindmahato/)
[![YouTube](https://img.shields.io/badge/YouTube-TechMahato-FF0000?style=for-the-badge&logo=youtube)](https://www.youtube.com/@TechMahato)
[![Website](https://img.shields.io/badge/Website-techmahato.com-00C7B7?style=for-the-badge&logo=google-chrome&logoColor=white)](https://techmahato.com/devops-project)

---

## ⭐ Support

If you found this project helpful:

- ⭐ **Star** this repository
- 🔀 **Fork** it and build your own version
- 📢 **Share** it with your network
- 🐛 **Report issues** or suggest improvements

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <b>Built with ❤️ by <a href="https://www.linkedin.com/in/arbindmahato/">Arbind Mahato</a> | <a href="https://techmahato.com/devops-project">TechMahato</a></b>
</p>
