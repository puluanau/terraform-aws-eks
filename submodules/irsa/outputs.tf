output "roles" {
  description = "Map of IRSA IAM Role Name/ARN."
  value = { for op in local.oidc_providers : op.role_name => {
    name = aws_iam_role.this[op.role_name].name
    arn  = aws_iam_role.this[op.role_name].arn
    }
  }
}
