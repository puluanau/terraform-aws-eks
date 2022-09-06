
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

output "managed_nodes_role_arns" {
  description = "EKS managed nodes arns."
  value       = [aws_iam_role.eks_nodes.arn]
}

output "eks_master_role_name" {
  description = "EKS master role arns."
  value       = [aws_iam_role.eks_cluster.name]
}

output "hosted_zone_id" {
  description = "DNS hosted zone ID."
  value       = data.aws_route53_zone.this.zone_id
}
