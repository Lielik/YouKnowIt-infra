output "role_arn" {
  description = "ARN of the IAM role for ESO's controller ServiceAccount (IRSA)"
  value       = module.eso_irsa.role_arn
}
