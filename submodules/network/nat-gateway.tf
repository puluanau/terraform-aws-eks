resource "aws_eip" "public" {
  for_each             = local.public_subnets
  network_border_group = var.region
  public_ipv4_pool     = "amazon"
  vpc                  = true
  tags = {
    "Name" = each.value.name
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each          = local.public_subnets
  allocation_id     = aws_eip.public[each.key].allocation_id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[each.key].id
  tags = {
    "Name" = each.value.name
  }
  depends_on = [aws_internet_gateway.igw]
}
