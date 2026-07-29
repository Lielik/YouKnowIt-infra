resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.project_name}/dev/app"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = var.secret_key
}

resource "aws_secretsmanager_secret" "database_url" {
  name                    = "${var.project_name}/dev/database-url"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}/${var.db_name}?sslmode=require"
}

resource "aws_secretsmanager_secret" "grafana_admin" {
  name                    = "${var.project_name}/grafana/admin"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id = aws_secretsmanager_secret.grafana_admin.id
  secret_string = jsonencode({
    "admin-user"     = var.grafana_admin_user
    "admin-password" = var.grafana_admin_password
  })
}

resource "aws_secretsmanager_secret" "alertmanager_slack" {
  name                    = "${var.project_name}/alertmanager/slack"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "alertmanager_slack" {
  secret_id = aws_secretsmanager_secret.alertmanager_slack.id
  secret_string = jsonencode({
    "webhook-url" = var.slack_webhook_url
  })
}
