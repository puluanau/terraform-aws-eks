
locals {
  oidc_providers = [
    {
      provider_arn               = var.eks_info.cluster.oidc.arn
      provider_url               = var.eks_info.cluster.oidc.url
      role_name                  = var.storage_info.irsa.iam_role_name
      iam_policy_arn             = var.storage_info.irsa.iam_policy_arn
      namespace_service_accounts = var.eks_info.cluster.irsa.namespace_service_accounts
  }]
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:CreateGrant"
    ]
  }
}

resource "aws_iam_policy" "kms" {
  name   = "${var.deploy_id}-kms-irsa"
  policy = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "this" {
  for_each = { for op in local.oidc_providers : op.role_name => op }

  dynamic "statement" {
    for_each = each.value.namespace_service_accounts

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [each.value.provider_arn]
      }

      condition {
        test     = endswith(statement.value, "*") ? "StringLike" : "StringEquals"
        variable = "${replace(each.value.provider_url, "https://", "")}:sub"
        values   = ["system:serviceaccount:${statement.value}"]

      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each           = { for op in local.oidc_providers : op.role_name => op }
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.this[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3" {
  for_each   = { for op in local.oidc_providers : op.role_name => op }
  policy_arn = each.value.iam_policy_arn
  role       = aws_iam_role.this[each.key].name
}
resource "aws_iam_role_policy_attachment" "kms" {
  for_each   = { for op in local.oidc_providers : op.role_name => op }
  policy_arn = aws_iam_policy.kms.arn
  role       = aws_iam_role.this[each.key].name
}
