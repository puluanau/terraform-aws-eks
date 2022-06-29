resource "aws_nat_gateway" "ngw" {
  for_each          = { for sb in var.public_subnets : sb.zone => sb }
  allocation_id     = aws_eip.public[each.value.name].allocation_id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[each.value.name].id
  tags              = merge({ "Name" = each.value.name }, { "zone" = each.value.zone }, var.tags)
  depends_on        = [aws_internet_gateway.igw]
}
