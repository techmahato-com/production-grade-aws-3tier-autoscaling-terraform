output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "nginx_log_group" {
  value = aws_cloudwatch_log_group.nginx.name
}

output "tomcat_log_group" {
  value = aws_cloudwatch_log_group.tomcat.name
}
