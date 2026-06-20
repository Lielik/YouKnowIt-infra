output "bucket_name" {
  description = "Name of the S3 bucket used for Loki logs"
  value       = aws_s3_bucket.loki.id
}

output "role_arn" {
  description = "ARN of the IAM role for Loki's ServiceAccount (IRSA)"
  value       = module.loki_irsa.role_arn
}
