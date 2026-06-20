variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider, without the https:// prefix"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the ServiceAccount that will assume this role"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes ServiceAccount that will assume this role"
  type        = string
}

variable "policy_json" {
  description = "IAM policy document (JSON) defining what this role is allowed to do"
  type        = string
}
