variable "project_name" {
  description = "Name prefix used for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "secret_key" {
  description = "Secret key used for JWT token signing"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_endpoint" {
  description = "RDS endpoint (host:port) from the rds module output"
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL for Alertmanager notifications"
  type        = string
  sensitive   = true
}
