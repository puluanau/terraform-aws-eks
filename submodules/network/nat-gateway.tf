resource "aws_eip" "public" {
  for_each             = { for sb in local.public_subnets : sb.name => sb }
  network_border_group = var.region
  public_ipv4_pool     = "amazon"
  vpc                  = true
  tags = {
    "Name" = each.value.name
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each          = { for sb in local.public_subnets : sb.zone => sb }
  allocation_id     = aws_eip.public[each.value.name].allocation_id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[each.value.name].id
  tags = {
    "Name" = each.value.name
    "zone" = each.value.zone
  }
  depends_on = [aws_internet_gateway.igw]
}
