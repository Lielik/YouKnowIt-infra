data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eso_secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }
}

module "eso_irsa" {
  source = "../irsa"

  role_name            = "${var.project_name}-${var.environment}-eso"
  oidc_provider_arn    = var.oidc_provider_arn
  oidc_provider_url    = var.oidc_provider_url
  namespace            = "external-secrets"
  service_account_name = "external-secrets"
  policy_json          = data.aws_iam_policy_document.eso_secrets_manager.json
}
