
## EKS Nodes
data "aws_iam_policy_document" "eks_nodes" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${local.dns_suffix}"]
    }
  }
}

data "aws_route53_zone" "this" {
  name         = var.route53_hosted_zone_name
  private_zone = false
}

resource "aws_iam_role" "eks_nodes" {
  name               = "${var.deploy_id}-eks-nodes"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes.json
  tags               = var.tags
}

locals {
  # gpu_bootstrap_extra_args = "--node-labels lifecycle=OnDemand  --node-labels=dominodatalab.com/node-pool=default-gpu,nvidia.com/gpu=true,dominodatalab.com/domino-node=true --register-with-taints=nvidia.com/gpu=true:NoSchedule"

  aws_route53_zone_arn     = data.aws_route53_zone.this.arn
  gpu_bootstrap_extra_args = ""
  gpu_user_data = base64encode(templatefile("${path.module}/templates/linux_custom.tpl", {
    cluster_name             = aws_eks_cluster.this.name
    cluster_endpoint         = aws_eks_cluster.this.endpoint
    cluster_auth_base64      = aws_eks_cluster.this.certificate_authority[0].data
    bootstrap_extra_args     = local.gpu_bootstrap_extra_args
    pre_bootstrap_user_data  = ""
    post_bootstrap_user_data = "echo ALL DONE !!!"
  }))
  node_group_gpu_ami_id = var.node_groups.gpu.ami != null ? var.node_groups.gpu.ami : data.aws_ami.eks_gpu.image_id
  # node_group_compute_ami_id = var.node_groups.compute.ami != null ? var.node_groups.compute.ami : data.aws_ami.eks_gpu.image_id
}


resource "aws_security_group" "eks_nodes" {
  name        = "${var.deploy_id}-nodes"
  description = "EKS cluster Nodes security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
  tags = merge({ "Name" = "${var.deploy_id}-eks-nodes" }, var.tags)
}

resource "aws_security_group_rule" "node" {
  for_each = local.node_security_group_rules

  # Required
  security_group_id = aws_security_group.eks_nodes.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type
  description       = each.value.description
  cidr_blocks       = try(each.value.cidr_blocks, null)
  self              = try(each.value.self, null)
  source_security_group_id = try(
    each.value.source_security_group_id,
    try(each.value.source_cluster_security_group, false) ? aws_security_group.eks_cluster.id : null
  )
}

data "aws_ami" "eks_gpu" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.k8s_version}-v*"]
  }
  most_recent = true
  owners      = ["amazon"]
}

resource "aws_launch_template" "compute" {
  name                    = "${var.deploy_id}-compute"
  disable_api_termination = "false"
  instance_type           = var.node_groups.compute.instance_type
  key_name                = var.ssh_pvt_key_name
  vpc_security_group_ids  = [aws_security_group.eks_nodes.id]
  image_id                = var.node_groups.compute.ami

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = var.node_groups.compute.volume.size
      volume_type           = var.node_groups.compute.volume.type
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "2"
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name" = "${var.deploy_id}-compute"
    }, var.tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge({ "Name" = "${var.deploy_id}-compute" }, var.tags)
  }
  tags = var.tags
}

resource "aws_eks_node_group" "compute" {
  for_each        = { for sb in var.private_subnets : sb.zone => sb if lookup(var.node_groups, "compute", {}) != {} }
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.deploy_id}-compute-${each.value.zone}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [each.value.id]
  tags            = var.tags
  scaling_config {
    min_size     = var.node_groups.compute.min_per_az
    max_size     = var.node_groups.compute.max_per_az
    desired_size = var.node_groups.compute.desired_per_az
  }

  launch_template {
    id      = aws_launch_template.compute.id
    version = aws_launch_template.compute.latest_version
  }


  labels = {
    "lifecycle"                     = "OnDemand"
    "dominodatalab.com/node-pool"   = "default"
    "dominodatalab.com/domino-node" = "true"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_nodes,
    aws_iam_role_policy_attachment.custom_eks_nodes
  ]
}

resource "aws_launch_template" "platform" {
  name                    = "${var.deploy_id}-platform"
  disable_api_termination = "false"
  instance_type           = var.node_groups.platform.instance_type
  key_name                = var.ssh_pvt_key_name
  vpc_security_group_ids  = [aws_security_group.eks_nodes.id]
  image_id                = var.node_groups.platform.ami

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = var.node_groups.platform.volume.size
      volume_type           = var.node_groups.platform.volume.type
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "2"
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name" = "${var.deploy_id}-platform"
    }, var.tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge({ "Name" = "${var.deploy_id}-platform" }, var.tags)
  }
  tags = var.tags
}

resource "aws_eks_node_group" "platform" {
  for_each        = { for sb in var.private_subnets : sb.zone => sb if lookup(var.node_groups, "platform", {}) != {} }
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.deploy_id}-platform-${each.value.zone}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [each.value.id]
  tags            = var.tags
  scaling_config {
    min_size     = var.node_groups.platform.min_per_az
    max_size     = var.node_groups.platform.max_per_az
    desired_size = var.node_groups.platform.desired_per_az
  }

  launch_template {
    id      = aws_launch_template.platform.id
    version = aws_launch_template.platform.latest_version
  }


  labels = {
    "lifecycle"                     = "OnDemand"
    "dominodatalab.com/node-pool"   = "platform"
    "dominodatalab.com/domino-node" = "true"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_nodes,
    aws_iam_role_policy_attachment.custom_eks_nodes
  ]
}

resource "aws_launch_template" "gpu" {
  name                    = "${var.deploy_id}-gpu"
  image_id                = local.node_group_gpu_ami_id
  disable_api_termination = "false"
  instance_type           = var.node_groups.gpu.instance_type
  key_name                = var.ssh_pvt_key_name
  vpc_security_group_ids  = [aws_security_group.eks_nodes.id]
  user_data               = local.gpu_user_data
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = var.node_groups.gpu.volume.size
      volume_type           = var.node_groups.gpu.volume.type
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "2"
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name" = "${var.deploy_id}-gpu"
    }, var.tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge({ "Name" = "${var.deploy_id}-gpu" }, var.tags)
  }
  tags = var.tags
}

resource "aws_eks_node_group" "gpu" {
  for_each        = { for sb in var.private_subnets : sb.zone => sb if lookup(var.node_groups, "gpu", {}) != {} }
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.deploy_id}-gpu-${each.value.zone}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [each.value.id]
  tags            = var.tags
  scaling_config {
    min_size     = var.node_groups.gpu.min_per_az
    max_size     = var.node_groups.gpu.max_per_az
    desired_size = var.node_groups.gpu.desired_per_az
  }

  launch_template {
    id      = aws_launch_template.gpu.id
    version = aws_launch_template.gpu.latest_version
  }

  taint {
    key    = "nvidia.com/gpu"
    value  = "true"
    effect = "NO_SCHEDULE"
  }
  labels = {
    "lifecycle"                     = "OnDemand"
    "dominodatalab.com/node-pool"   = "default-gpu"
    "dominodatalab.com/domino-node" = "true"
    "nvidia.com/gpu"                = "true"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_nodes,
    aws_iam_role_policy_attachment.custom_eks_nodes
  ]
}
