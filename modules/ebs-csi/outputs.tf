output "addon_arn" {
  description = "ARN of the EBS CSI EKS addon"
  value       = aws_eks_addon.ebs_csi.arn
}

output "role_arn" {
  description = "ARN of the IAM role for the EBS CSI driver's ServiceAccount (IRSA)"
  value       = module.ebs_csi_irsa.role_arn
}
