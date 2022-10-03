resource "aws_route_table" "public" {
  for_each = { for sb in local.public_subnets : sb.name => sb }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  vpc_id = local.vpc_id
  tags = {
    "Name"                                   = each.value.name,
    "kubernetes.io/role/elb"                 = "1",
    "kubernetes.io/cluster/${var.deploy_id}" = "shared",
  }

}

resource "aws_route_table_association" "public" {
  for_each       = { for sb in local.public_subnets : sb.name => sb }
  subnet_id      = aws_subnet.public[each.value.name].id
  route_table_id = aws_route_table.public[each.value.name].id
}

resource "aws_route_table" "private" {
  for_each = { for sb in local.private_subnets : sb.name => sb }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[each.value.zone].id
  }
  vpc_id = local.vpc_id
  tags = {
    "Name"                                   = each.value.name,
    "kubernetes.io/role/internal-elb"        = "1",
    "kubernetes.io/cluster/${var.deploy_id}" = "shared",
  }
}

resource "aws_route_table_association" "private" {
  for_each       = { for sb in local.private_subnets : sb.name => sb }
  subnet_id      = aws_subnet.private[each.value.name].id
  route_table_id = aws_route_table.private[each.value.name].id
}
