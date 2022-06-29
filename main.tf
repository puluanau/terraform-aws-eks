resource "tls_private_key" "domino" {
  algorithm = "RSA"
}


resource "aws_key_pair" "domino" {
  key_name   = var.deploy_id
  public_key = trimspace(tls_private_key.domino.public_key_openssh)
}

resource "local_sensitive_file" "pvt_key" {
  content         = tls_private_key.domino.private_key_openssh
  file_permission = "0400"
  filename        = local.ssh_pvt_key_path
}


data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

locals {
  availability_zones_data = zipmap(data.aws_availability_zones.available.names, data.aws_availability_zones.available.zone_ids)
  ## EKS needs at least 2 availability zones: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  availability_zone_names = length(var.availability_zones) >= 2 ? toset(var.availability_zones) : toset(slice(keys(local.availability_zones_data), 0, var.number_of_azs))
  availability_zone_ids   = [for name in local.availability_zone_names : local.availability_zones_data[name]]
  availability_zones      = zipmap(local.availability_zone_names, local.availability_zone_ids)
  bastion_user            = "ec2-user"
  ssh_pvt_key_path        = "resources/${var.deploy_id}/${var.ssh_pvt_key_name}"
  kubeconfig_path         = "resources/${var.deploy_id}/kubeconfig"
}

module "subnets_cidr" {
  source                    = "./submodules/subnets-cidr"
  availability_zones        = local.availability_zones
  base_cidr_block           = var.base_cidr_block
  public_cidr_network_bits  = var.public_cidr_network_bits
  private_cidr_network_bits = var.private_cidr_network_bits
  subnet_name_prefix        = var.deploy_id
}

module "network" {
  source                   = "./submodules/network"
  region                   = var.region
  public_subnets           = module.subnets_cidr.public_subnets
  private_subnets          = module.subnets_cidr.private_subnets
  deploy_id                = var.deploy_id
  base_cidr_block          = var.base_cidr_block
  vpc_id                   = var.vpc_id
  monitoring_s3_bucket_arn = module.storage.monitoring_s3_bucket_arn
  tags                     = var.tags
}

locals {
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
}


module "storage" {
  source                = "./submodules/storage"
  deploy_id             = var.deploy_id
  efs_access_point_path = var.efs_access_point_path
  route53_hosted_zone   = var.route53_hosted_zone
  subnets = [for s in local.private_subnets : {
    name       = s.name
    id         = s.id
    cidr_block = s.cidr_block
  }]
  vpc_id = module.network.vpc_id
  tags   = var.tags
}

module "bastion" {
  count = var.create_bastion ? 1 : 0

  source                   = "./submodules/bastion"
  region                   = var.region
  vpc_id                   = module.network.vpc_id
  deploy_id                = var.deploy_id
  ssh_pvt_key_name         = aws_key_pair.domino.key_name
  bastion_public_subnet_id = local.public_subnets[0].id
  tags                     = var.tags
}

module "eks" {
  source                    = "./submodules/eks"
  region                    = var.region
  k8s_version               = var.k8s_version
  vpc_id                    = module.network.vpc_id
  deploy_id                 = var.deploy_id
  private_subnets           = local.private_subnets
  ssh_pvt_key_name          = aws_key_pair.domino.key_name
  route53_hosted_zone       = var.route53_hosted_zone
  bastion_security_group_id = try(module.bastion[0].security_group_id, "")
  create_bastion_sg         = var.create_bastion
  enable_route53_iam_policy = var.enable_route53_iam_policy
  kubeconfig_path           = local.kubeconfig_path
  node_groups               = var.node_groups
  s3_buckets                = module.storage.s3_buckets
  tags                      = var.tags
}


module "k8s_setup" {
  source                  = "./submodules/k8s"
  deploy_id               = var.deploy_id
  ssh_pvt_key_name        = abspath(local.ssh_pvt_key_path)
  bastion_user            = local.bastion_user
  bastion_public_ip       = try(module.bastion[0].public_ip, "")
  k8s_cluster_endpoint    = module.eks.cluster_endpoint
  managed_nodes_role_arns = module.eks.managed_nodes_role_arns
  eks_master_role_names   = concat(var.eks_master_role_names, module.eks.eks_master_role_name)
  kubeconfig_path         = local.kubeconfig_path
  depends_on = [
    module.eks,
    module.bastion
  ]
}
