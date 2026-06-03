variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
}

variable "project_name" {
  description = "Name prefix used for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}
