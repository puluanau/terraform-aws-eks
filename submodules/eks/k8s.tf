data "aws_iam_role" "eks_master_roles" {
  for_each = var.create_bastion_sg ? toset(var.eks_master_role_names) : []
  name     = each.key
}

module "k8s_setup" {
  count                = var.create_bastion_sg ? 1 : 0
  source               = "../k8s"
  ssh_pvt_key_path     = var.ssh_pvt_key_path
  bastion_user         = var.bastion_user
  bastion_public_ip    = try(var.bastion_public_ip, "")
  eks_node_role_arns   = [aws_iam_role.eks_nodes.arn]
  eks_master_role_arns = [for r in concat(values(data.aws_iam_role.eks_master_roles), [aws_iam_role.eks_cluster]) : r.arn]
  kubeconfig_path      = var.kubeconfig_path

  security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  internal_subnets  = var.internal_subnets

  depends_on = [aws_eks_addon.vpc_cni, null_resource.kubeconfig]
}