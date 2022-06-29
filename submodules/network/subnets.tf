resource "aws_subnet" "public" {
  for_each = { for sb in var.public_subnets : sb.name => sb }

  availability_zone_id = each.value.zone_id
  vpc_id               = local.vpc_id
  cidr_block           = each.value.cidr_block
  tags = merge(
    {
      "Name"                                   = each.value.name,
      "kubernetes.io/role/elb"                 = "1",
      "kubernetes.io/cluster/${var.deploy_id}" = "shared",
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  for_each = { for sb in var.private_subnets : sb.name => sb }

  availability_zone_id = each.value.zone_id
  vpc_id               = local.vpc_id
  cidr_block           = each.value.cidr_block
  tags = merge(
    {
      "Name"                                   = each.value.name,
      "kubernetes.io/role/internal-elb"        = "1",
      "kubernetes.io/cluster/${var.deploy_id}" = "shared",
    },
    var.tags
  )
}
