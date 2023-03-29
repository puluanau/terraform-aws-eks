output "role_arn" {
  description = "IRSA IAM Role ARN."
  value       = var.irsa_enabled ? aws_iam_role.service_account[0].arn : null
}
