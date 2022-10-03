output "vpc_id" {
  description = "VPC id."
  value       = local.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [for sb in aws_subnet.private : sb.id]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [for sb in aws_subnet.public : sb.id]
}
