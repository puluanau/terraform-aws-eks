output "public_subnets" {
  description = "Map containing the CIDR information for the public subnets"
  value = [for k, v in local.public_subnets :
    {
      name       = v.name
      cidr_block = v.cidr_block
      zone       = v.zone
      zone_id    = v.zone_id
      type       = v.type
    }
  ]
}

output "private_subnets" {
  description = "Map containing the CIDR information for the private subnets"
  value = [for k, v in local.private_subnets :
    {
      name       = v.name
      cidr_block = v.cidr_block
      zone       = v.zone
      zone_id    = v.zone_id
      type       = v.type
    }
  ]
}
