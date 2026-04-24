output "web_asg_name" {
  value = aws_autoscaling_group.web.name
}

output "web_asg_arn" {
  value = aws_autoscaling_group.web.arn
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}

output "app_asg_arn" {
  value = aws_autoscaling_group.app.arn
}

output "web_launch_template_id" {
  value = aws_launch_template.web.id
}

output "app_launch_template_id" {
  value = aws_launch_template.app.id
}
