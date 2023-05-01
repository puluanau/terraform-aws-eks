output "role_arn" {
  description = "IRSA IAM Role ARN."
  value       = aws_iam_role.this[var.storage_info.irsa.iam_role_name].arn
}
