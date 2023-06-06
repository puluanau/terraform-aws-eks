locals {
  eks_irsa_context = {
    provider_arn               = var.eks_info.cluster.oidc.arn
    provider_url               = var.eks_info.cluster.oidc.url
    role_name                  = var.eks_info.cluster.irsa.role_name
    iam_policy_arns            = [var.eks_info.cluster.irsa.kms_policy_arn, var.storage_info.irsa.iam_policy_arn]
    namespace_service_accounts = var.eks_info.cluster.irsa.namespace_service_accounts
  }
  oidc_providers = [
    local.eks_irsa_context
  ]
  policy_attachments = flatten([for op in local.oidc_providers : [
    for iam_policy_arn in op.iam_policy_arns : {
      role_name      = op.role_name
      iam_policy_arn = iam_policy_arn
    }
  ]])
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

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(local.policy_attachments)
  policy_arn = local.policy_attachments[count.index].iam_policy_arn
  role       = aws_iam_role.this[local.policy_attachments[count.index].role_name].name
}

locals {
  irsa_info = {
    eks_irsa_role = aws_iam_role.this[local.eks_irsa_context.role_name]
  }
}