output "app_secret_arn" {
  description = "ARN of the app secret (SECRET_KEY)"
  value       = aws_secretsmanager_secret.app.arn
}

output "database_url_secret_arn" {
  description = "ARN of the database URL secret"
  value       = aws_secretsmanager_secret.database_url.arn
}

output "grafana_admin_secret_arn" {
  description = "ARN of the Grafana admin credentials secret"
  value       = aws_secretsmanager_secret.grafana_admin.arn
}

output "alertmanager_slack_secret_arn" {
  description = "ARN of the Alertmanager Slack webhook secret"
  value       = aws_secretsmanager_secret.alertmanager_slack.arn
}
