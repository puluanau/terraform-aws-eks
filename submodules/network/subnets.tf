locals {
  az = sort(var.availability_zones)

  ## Get the public subnets by matching the mask and populating its params
  public_cidrs = { for i, cidr in var.public_cidrs : cidr =>
    {
      "az"   = element(local.az, i)
      "name" = "${var.deploy_id}-public-${element(local.az, i)}"
    }
  }

  ## Get the private subnets by matching the mask and populating its params
  private_cidrs = { for i, cidr in var.private_cidrs : cidr =>
    {
      "az"   = element(local.az, i)
      "name" = "${var.deploy_id}-private-${element(local.az, i)}"
    }
  }

  ## Get the pod subnets by matching the mask and populating its params
  pod_cidrs = { for i, cidr in var.pod_cidrs : cidr =>
    {
      "az"   = element(local.az, i)
      "name" = "${var.deploy_id}-pod-${element(local.az, i)}"
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_cidrs

  availability_zone = each.value.az
  vpc_id            = local.vpc_id
  cidr_block        = each.key
  tags = merge(
    { "Name" : each.value.name },
    var.add_eks_elb_tags ? {
      "kubernetes.io/role/elb"                 = "1"
      "kubernetes.io/cluster/${var.deploy_id}" = "shared"
  } : {})

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_cidrs

  availability_zone = each.value.az
  vpc_id            = local.vpc_id
  cidr_block        = each.key
  tags = merge(
    { "Name" : each.value.name },
    var.add_eks_elb_tags ? {
      "kubernetes.io/role/internal-elb"        = "1"
      "kubernetes.io/cluster/${var.deploy_id}" = "shared"
  } : {})

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "pod" {
  for_each = local.pod_cidrs

  availability_zone = each.value.az
  vpc_id            = local.vpc_id
  cidr_block        = each.key
  tags = merge(
    { "Name" : each.value.name },
    var.add_eks_elb_tags ? {
      "kubernetes.io/role/internal-elb"        = "1"
      "kubernetes.io/cluster/${var.deploy_id}" = "shared"
  } : {})

  lifecycle {
    ignore_changes = [tags]
  }

  ## See https://github.com/hashicorp/terraform-provider-aws/issues/9592
  depends_on = [aws_vpc_ipv4_cidr_block_association.pod_cidr[0]]
}
