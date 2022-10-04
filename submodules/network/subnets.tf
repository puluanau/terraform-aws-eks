locals {
  az = sort(var.availability_zones)
  ## Get the public subnets by matching the mask and populating its params
  public_subnets = { for i, sn in var.public_subnets : sn =>
    {
      "cidr" = sn,
      "az"   = element(local.az, i)
      "name" = "${var.deploy_id}-public-${i + 1}"
    }
  }

  ## Get the private subnets by matching the mask and populating its params
  private_subnets = { for i, sn in var.private_subnets : sn =>
    {
      "cidr" = sn,
      "az"   = element(local.az, i)
      "name" = "${var.deploy_id}-private-${i + 1}"
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  availability_zone = each.value.az
  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr
  tags = {
    "Name"                                   = each.value.name
    "kubernetes.io/role/elb"                 = "1",
    "kubernetes.io/cluster/${var.deploy_id}" = "shared",
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  availability_zone = each.value.az
  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr
  tags = {
    "Name"                                   = each.value.name
    "kubernetes.io/role/internal-elb"        = "1",
    "kubernetes.io/cluster/${var.deploy_id}" = "shared",
  }
}
