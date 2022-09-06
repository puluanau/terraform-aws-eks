resource "aws_internet_gateway" "igw" {
  # vpc_id = local.vpc_id
  tags = {
    "Name" = "${var.deploy_id}-domino-igw"
  }
}

resource "aws_internet_gateway_attachment" "this" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = local.vpc_id
}

resource "aws_eip" "public" {
  for_each             = { for sb in var.public_subnets : sb.name => sb }
  network_border_group = var.region
  public_ipv4_pool     = "amazon"
  vpc                  = true
  tags = {
    "Name" = each.value.name
  }
  depends_on = [aws_internet_gateway.igw]
}
