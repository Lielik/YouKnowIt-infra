output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "Certificate authority data for the EKS cluster"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "db_endpoint" {
  description = "Endpoint of the RDS database"
  value       = module.rds.db_endpoint
}

output "db_name" {
  description = "Name of the database"
  value       = module.rds.db_name
}

output "db_port" {
  description = "Port of the database"
  value       = module.rds.db_port
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider, without the https:// prefix"
  value       = module.eks.oidc_provider_url
}

output "loki_s3_bucket_name" {
  description = "S3 bucket name for Loki logs"
  value       = module.loki_storage.bucket_name
}

output "loki_iam_role_arn" {
  description = "IAM role ARN for Loki's ServiceAccount (IRSA)"
  value       = module.loki_storage.role_arn
}

output "eso_iam_role_arn" {
  description = "IAM role ARN for ESO's ServiceAccount (IRSA)"
  value       = module.eso_iam.role_arn
}
