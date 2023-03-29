output "security_group_id" {
  description = "EKS security group id."
  value       = aws_security_group.eks_cluster.id
}

output "nodes_security_group_id" {
  description = "EKS managed nodes security group id."
  value       = aws_security_group.eks_nodes.id
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "eks_node_roles" {
  description = "EKS managed node roles"
  value       = [aws_iam_role.eks_nodes]
}

output "eks_master_roles" {
  description = "EKS master roles."
  value       = [aws_iam_role.eks_cluster]
}

output "oidc_provider_arn" {
  description = "Cluster IAM OIDC Provider ARN."
  value       = var.irsa_enabled ? aws_iam_openid_connect_provider.oidc_provider.arn : null
}

output "oidc_provider_url" {
  description = "Cluster IAM OIDC Provider URL."
  value       = var.irsa_enabled ? aws_iam_openid_connect_provider.oidc_provider.url : null
}
