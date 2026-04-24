# 🏗️ Production-Grade AWS 3-Tier Architecture with Auto Scaling — Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Arbind%20Mahato-0A66C2?logo=linkedin)](https://www.linkedin.com/in/arbindmahato/)

> Enterprise-grade, fully automated AWS infrastructure for deploying a Java-based web application using a secure, scalable, and highly available 3-tier architecture — provisioned entirely with Terraform.

---

## 📐 Architecture Overview

```
                         ┌──────────────┐
                         │  CloudFront   │ (Optional CDN)
                         └──────┬───────┘
                                │
                         ┌──────▼───────┐
                         │   AWS WAF     │
                         └──────┬───────┘
                                │
                    ┌───────────▼───────────┐
                    │  Internet Gateway (IGW)│
                    └───────────┬───────────┘
                                │
               ┌────────────────▼────────────────┐
               │     Application Load Balancer    │
               │         (Internet-Facing)        │
               └──────┬─────────────────┬────────┘
                      │                 │
          ┌───────────▼──┐        ┌─────▼──────────┐
          │  AZ: us-east-1a│      │  AZ: us-east-1b │
          ├──────────────┤        ├────────────────┤
          │ Public Subnet │        │ Public Subnet  │
          │ ┌──────────┐ │        │ ┌──────────┐   │
          │ │  Nginx   │ │        │ │  Nginx   │   │
          │ │  (ASG)   │ │        │ │  (ASG)   │   │
          │ └────┬─────┘ │        │ └────┬─────┘   │
          ├──────┼───────┤        ├──────┼─────────┤
          │ Private Sub  │        │ Private Sub    │
          │ ┌────▼─────┐ │        │ ┌────▼─────┐   │
          │ │ Tomcat   │ │        │ │ Tomcat   │   │
          │ │  (ASG)   │ │        │ │  (ASG)   │   │
          │ └────┬─────┘ │        │ └────┬─────┘   │
          ├──────┼───────┤        ├──────┼─────────┤
          │ Private Sub  │        │ Private Sub    │
          │ ┌────▼─────┐ │        │ ┌────▼─────┐   │
          │ │ RDS MySQL│ │        │ │ RDS MySQL│   │
          │ │ (Primary)│ │        │ │(Standby) │   │
          │ └──────────┘ │        │ └──────────┘   │
          └──────────────┘        └────────────────┘
```

### Three Tiers

| Tier | Component | Subnet | Scaling |
|------|-----------|--------|---------|
| **Presentation** | Nginx Web Servers | Public | Auto Scaling Group (2–6 instances) |
| **Application** | Apache Tomcat (Java/Spring Boot) | Private | Auto Scaling Group (2–6 instances) |
| **Data** | Amazon RDS MySQL (Multi-AZ) | Private (Isolated) | Vertical + Read Replicas |

---

## 🚀 Key Features

- **High Availability** — Multi-AZ deployment across `us-east-1a` and `us-east-1b` with automated failover
- **Auto Scaling** — Dynamic scaling policies based on CPU utilization for both web and app tiers
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

# 5. Destroy when done (careful in production!)
terraform destroy -var-file=environments/prod/terraform.tfvars
```

---

## 📦 Implementation Phases

### Phase 1 — Network & Foundation
- VPC with CIDR `10.0.0.0/16`
- 6 Subnets (2 public, 2 private app, 2 private data) across 2 AZs
- Internet Gateway + NAT Gateway (per AZ for HA)
- Route tables with proper associations

### Phase 2 — Security Configuration
- **Security Groups**: Web tier (80/443 from internet), App tier (8080 from web SG only), Data tier (3306 from app SG only)
- **NACLs**: Stateless firewall rules per subnet tier
- **IAM Roles**: EC2 instance profiles with least-privilege policies for CloudWatch, S3, and SSM

### Phase 3 — Database Deployment
- RDS MySQL `db.t3.medium` in Multi-AZ
- Private DB subnet group (no public access)
- Automated backups (7-day retention) with point-in-time recovery
- Encryption at rest (AWS KMS)

### Phase 4 — Application Deployment
- **Tomcat**: Java 11, Spring Boot app served on port 8080 via systemd service
- **Nginx**: Reverse proxy forwarding traffic to internal ALB → Tomcat backend
- User data scripts for automated bootstrapping

### Phase 5 — Load Balancing & Auto Scaling
- **External ALB**: Internet-facing, routes HTTP/HTTPS to Nginx target group
- **Internal ALB**: Routes traffic from Nginx to Tomcat target group
- **ASG Policies**: Scale out at 70% CPU, scale in at 30% CPU
- Health checks: ELB-based with 300s grace period

### Phase 6 — CI/CD Integration
- Git-based source control
- SonarQube for static code analysis
- JFrog Artifactory for Maven artifact storage
- Pipeline-ready architecture for Jenkins/GitHub Actions

### Phase 7 — Monitoring & Observability
- CloudWatch Alarms: CPU, memory, disk, HTTP 5xx errors
- Custom metrics via CloudWatch Agent (memory, swap usage)
- Centralized logging: Tomcat `catalina.out` → CloudWatch Log Groups
- CloudWatch Dashboard for real-time visibility

### Phase 8 — Security & Compliance
- Encryption at rest (EBS, RDS, S3) and in transit (TLS/SSL)
- AWS WAF with rate-limiting and SQL injection protection
- VPC Flow Logs enabled for network audit
- AWS Shield Standard for DDoS protection

---

## 🔐 Security Architecture

```
Internet → WAF → ALB (HTTPS/TLS) → Nginx (Public Subnet)
                                        │
                                   [Security Group: Allow 8080 from Web SG only]
                                        │
                                   Internal ALB → Tomcat (Private Subnet)
                                        │
                                   [Security Group: Allow 3306 from App SG only]
                                        │
                                   RDS MySQL (Isolated Private Subnet)
                                   [Encrypted at rest + in transit]
```

- No direct SSH access — use **AWS Systems Manager Session Manager**
- Secrets managed via **AWS Secrets Manager** (DB credentials, API keys)
- **VPC Flow Logs** → S3/CloudWatch for network forensics
- **GuardDuty** enabled for threat detection

---

## 📊 Estimated Monthly Cost

| Resource | Specification | Est. Cost (USD) |
|----------|--------------|-----------------|
| EC2 (Nginx ASG) | 2× t3.micro | ~$15 |
| EC2 (Tomcat ASG) | 2× t3.micro | ~$15 |
| ALB (External + Internal) | 2× ALB | ~$35 |
| RDS MySQL | db.t3.medium, Multi-AZ | ~$70 |
| NAT Gateway | 2× (per AZ) | ~$65 |
| CloudWatch | Metrics + Logs | ~$10 |
| S3 (State + Logs) | Minimal storage | ~$2 |
| **Total** | | **~$212/month** |

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
```

---

## 🔧 Troubleshooting

| Issue | Command | Resolution |
|-------|---------|------------|
| DB connectivity | `telnet <rds-endpoint> 3306` | Check app-tier SG allows 3306 from app SG |
| ALB health check failing | `aws elbv2 describe-target-health --target-group-arn <arn>` | Verify Tomcat is running on port 8080 |
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
