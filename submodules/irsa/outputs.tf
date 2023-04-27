output "role_arn" {
  description = "IRSA IAM Role ARN."
  value       = aws_iam_role.this[0].arn
}
