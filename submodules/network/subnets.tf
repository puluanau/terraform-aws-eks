locals {
  availability_zones        = var.availability_zones
  availability_zones_number = length(local.availability_zones)

  ## Calculating public and private subnets based on the base base cidr and desired network bits
  base_cidr_network_bits = tonumber(regex("[^/]*$", var.base_cidr_block))
  ## We have one Cidr to carve the nw bits for both pvt and public subnets
  ## `...local.availability_zones_number * 2)` --> we have 2 types private and public subnets
  new_bits_list       = [for n in range(0, local.availability_zones_number * 2) : (n % 2 == 0 ? var.private_cidr_network_bits - local.base_cidr_network_bits : var.public_cidr_network_bits - local.base_cidr_network_bits)]
  subnets_cidr_blocks = cidrsubnets(var.base_cidr_block, local.new_bits_list...)

  ## Match the public subnet var to the list of cidr blocks
  public_subnets_cidr_blocks = [for sn in local.subnets_cidr_blocks : sn if length(regexall(".*/${var.public_cidr_network_bits}.*", sn)) > 0]
  ## Match the private subnet var to the list of cidr blocks
  private_subnets_cidr_blocks = [for sn in local.subnets_cidr_blocks : sn if length(regexall(".*/${var.private_cidr_network_bits}.*", sn)) > 0]

  ## Get the public subnets by matching the mask and populating its params
  public_subnets = [
    for i, sn in local.public_subnets_cidr_blocks :
    {
      "cidr_block" = sn,
      "zone"       = element(keys(local.availability_zones), i % floor(i / length(local.availability_zones))),
      "zone_id"    = element(values(local.availability_zones), i % floor(i / length(local.availability_zones))),
      "name"       = "${var.deploy_id}-public-${element(keys(local.availability_zones), i % floor(i / length(local.availability_zones)))}-${i + 1}",
      "type"       = "public"
    }
  ]

  ## Get the private subnets by matching the mask and populating its params
  private_subnets = [
    for i, sn in local.private_subnets_cidr_blocks :
    {
      "cidr_block" = sn,
      "zone"       = element(keys(local.availability_zones), i % floor(i / length(local.availability_zones))),
      "zone_id"    = element(values(local.availability_zones), i % floor(i / length(local.availability_zones))),
      "name"       = "${var.deploy_id}-private-${element(keys(local.availability_zones), i % floor(i / length(local.availability_zones)))}-${i + 1}",
      "type"       = "private"
    }
  ]
}

resource "aws_subnet" "public" {
  for_each = { for sb in local.public_subnets : sb.name => sb }

  availability_zone_id = each.value.zone_id
  vpc_id               = local.vpc_id
  cidr_block           = each.value.cidr_block
  tags = {
    "Name"                                   = each.value.name,
    "kubernetes.io/role/elb"                 = "1",
    "kubernetes.io/cluster/${var.deploy_id}" = "shared",
  }
}

resource "aws_subnet" "private" {
  for_each = { for sb in local.private_subnets : sb.name => sb }

  availability_zone_id = each.value.zone_id
  vpc_id               = local.vpc_id
  cidr_block           = each.value.cidr_block
  tags = {
    "Name"                                   = each.value.name,
    "kubernetes.io/role/internal-elb"        = "1",
    "kubernetes.io/cluster/${var.deploy_id}" = "shared",
  }
}
