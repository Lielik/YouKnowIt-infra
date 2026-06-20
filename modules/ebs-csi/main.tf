data "aws_iam_policy" "ebs_csi" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "ebs_csi_irsa" {
  source = "../irsa"

  role_name            = "${var.project_name}-${var.environment}-ebs-csi"
  oidc_provider_arn    = var.oidc_provider_arn
  oidc_provider_url    = var.oidc_provider_url
  namespace            = "kube-system"
  service_account_name = "ebs-csi-controller-sa"
  policy_json          = data.aws_iam_policy.ebs_csi.policy
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = module.ebs_csi_irsa.role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-csi"
    Environment = var.environment
    Project     = var.project_name
  }
}
