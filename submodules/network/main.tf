data "aws_vpc" "this" {
  count = var.vpc_id != "" ? 1 : 0
  state = "available"
  id    = var.vpc_id
}

resource "aws_vpc" "this" {
  count                            = var.vpc_id != "" ? 0 : 1
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = var.base_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = var.deploy_id
  }
}

locals {
  vpc_id = var.vpc_id != "" ? data.aws_vpc.this[0].id : aws_vpc.this[0].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [for s in aws_route_table.public : s.id],
    [for s in aws_route_table.private : s.id]
  )

  tags = {
    "Name" = "${var.deploy_id}-s3"
  }
}

data "aws_network_acls" "default" {
  vpc_id = local.vpc_id

  filter {
    name   = "default"
    values = ["true"]
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = one(data.aws_network_acls.default.ids)

  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  subnet_ids = concat(
    [for s in aws_subnet.public : s.id],
    [for s in aws_subnet.private : s.id]
  )

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_flow_log" "this" {
  log_destination          = var.monitoring_s3_bucket_arn
  vpc_id                   = local.vpc_id
  max_aggregation_interval = 600
  log_destination_type     = "s3"
  traffic_type             = "REJECT"
}
