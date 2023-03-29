data "aws_iam_policy_document" "service_account_assume_role_policy" {
  count = var.irsa_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${service_account_name}"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "service_account" {
  count               = var.irsa_enabled ? 1 : 0
  name                = "${var.deploy_id}-${var.service_account_name}"
  assume_role_policy  = data.aws_iam_policy_document.service_account_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "nucleus_S3_to_nucleus_service_account" {
    count       = var.irsa_enabled ? 1 : 0
    policy_arn  = var.irsa_iam_policy
    role        = aws_iam_role.service_account.name
}
