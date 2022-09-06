output "vpc_id" {
  description = "VPC id."
  value       = local.vpc_id
}

output "private_subnets" {
  description = "Private subnets object. Adds id to the object"
  value = [for sb in var.private_subnets :
    {
      id         = aws_subnet.private[sb.name].id
      name       = sb.name
      cidr_block = sb.cidr_block
      zone       = sb.zone
      zone_id    = sb.zone_id
      type       = sb.type
    }
  ]
}

output "public_subnets" {
  description = "Public subnets object. Adds id to the object"
  value = [for sb in var.public_subnets :
    {
      id         = aws_subnet.public[sb.name].id
      name       = sb.name
      cidr_block = sb.cidr_block
      zone       = sb.zone
      zone_id    = sb.zone_id
      type       = sb.type
    }
  ]
}
