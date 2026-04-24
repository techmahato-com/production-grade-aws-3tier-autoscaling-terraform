locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Security Group — Bastion Host
# -----------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Allow SSH from trusted IPs only"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from trusted IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-bastion-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — External ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "external_alb" {
  name        = "${local.name_prefix}-ext-alb-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-ext-alb-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — Web Tier (Nginx)
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP from External ALB and SSH from Bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from External ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-web-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — Internal ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "internal_alb" {
  name        = "${local.name_prefix}-int-alb-sg"
  description = "Allow traffic from Web tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-int-alb-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — App Tier (Tomcat)
# -----------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow 8080 from Internal ALB and SSH from Bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Tomcat from Internal ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-app-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — Database Tier (RDS)
# -----------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Allow MySQL from App tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from App tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-db-sg" }
}

# -----------------------------------------------------------------------------
# IAM Role — EC2 Instance Profile (for CloudWatch, SSM, S3)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "${local.name_prefix}-ec2-role" }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# -----------------------------------------------------------------------------
# NACLs — Web Tier
# -----------------------------------------------------------------------------
resource "aws_network_acl" "web" {
  vpc_id = var.vpc_id
  tags   = { Name = "${local.name_prefix}-web-nacl" }
}

resource "aws_network_acl_rule" "web_inbound_http" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "web_inbound_ssh" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "web_inbound_ephemeral" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "web_outbound_all" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# -----------------------------------------------------------------------------
# NACLs — App Tier
# -----------------------------------------------------------------------------
resource "aws_network_acl" "app" {
  vpc_id = var.vpc_id
  tags   = { Name = "${local.name_prefix}-app-nacl" }
}

resource "aws_network_acl_rule" "app_inbound_tomcat" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 8080
  to_port        = 8080
}

resource "aws_network_acl_rule" "app_inbound_ssh" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "app_inbound_ephemeral" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "app_outbound_all" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# -----------------------------------------------------------------------------
# NACLs — Database Tier
# -----------------------------------------------------------------------------
resource "aws_network_acl" "db" {
  vpc_id = var.vpc_id
  tags   = { Name = "${local.name_prefix}-db-nacl" }
}

resource "aws_network_acl_rule" "db_inbound_mysql" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "db_inbound_ephemeral" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "db_outbound_ephemeral" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}
