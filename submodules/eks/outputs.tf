output "info" {
  description = "EKS information"
  value       = local.eks_info
}

output "oidc_provider_arn" {
  description = "Cluster IAM OIDC Provider ARN."
  value       = var.irsa_enabled ? aws_iam_openid_connect_provider.cluster_oidc_provider[0].arn : null
}

output "oidc_provider_url" {
  description = "Cluster IAM OIDC Provider URL."
  value       = var.irsa_enabled ? aws_iam_openid_connect_provider.cluster_oidc_provider[0].url : null
}
