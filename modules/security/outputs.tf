output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "external_alb_sg_id" {
  value = aws_security_group.external_alb.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_profile.arn
}

output "web_nacl_id" {
  value = aws_network_acl.web.id
}

output "app_nacl_id" {
  value = aws_network_acl.app.id
}

output "db_nacl_id" {
  value = aws_network_acl.db.id
}
