# Validating zone offerings.

# Check the zones where the instance types are being offered
data "aws_ec2_instance_type_offerings" "nodes" {
  for_each = toset([for ng in merge(var.default_node_groups, var.additional_node_groups) : ng.instance_type])

  filter {
    name   = "instance-type"
    values = [each.value]
  }

  location_type = "availability-zone"

  lifecycle {
    # Validating the number of zones is greater than 2. EKS needs at least 2.
    postcondition {
      condition     = length(toset(self.locations)) >= 2
      error_message = "Availability of the instance types does not satisfy the number of zones"
    }
  }
}

# Get "available" azs for the region
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

data "aws_subnet" "specified" {
  count = var.vpc_id != null ? length(var.private_subnets) : 0
  id    = element(var.private_subnets, count.index)
}

locals {
  # Get zones where ALL instance types are offered(intersection).
  zone_intersection_instance_offerings = setintersection([for k, v in data.aws_ec2_instance_type_offerings.nodes : toset(v.locations)]...)
  # Get the zones that are available and offered in the region for the instance types.
  az_names           = var.vpc_id != null ? distinct(data.aws_subnet.specified[*].availability_zone) : length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names
  offered_azs        = setintersection(local.zone_intersection_instance_offerings, toset(local.az_names))
  available_azs_data = zipmap(data.aws_availability_zones.available.names, data.aws_availability_zones.available.zone_ids)
  # Getting the required azs name and id.
}

# Validate that the number of offered and available zones satisfy the number of required zones. https://github.com/hashicorp/terraform/issues/31122 may result in a more elegant validation and deprecation of the null_data_source
data "null_data_source" "validate_zones" {
  inputs = {
    validated = true
  }
  lifecycle {
    precondition {
      condition     = length(local.offered_azs) >= (var.vpc_id != null ? length(local.az_names) : var.number_of_azs)
      error_message = "Availability of the instance types does not satisfy the desired number of zones, or the desired number of zones is higher than the available/offered zones"
    }
  }
}

locals {
  num_of_azs         = var.vpc_id != null ? 0 : var.number_of_azs
  availability_zones = { for name in slice(tolist(local.offered_azs), 0, local.num_of_azs) : name => local.available_azs_data[name] if data.null_data_source.validate_zones.outputs["validated"] }
  bastion_user       = "ec2-user"
  ssh_pvt_key_path   = abspath(pathexpand(var.ssh_pvt_key_path))
  kubeconfig_path    = var.kubeconfig_path != "" ? abspath(pathexpand(var.kubeconfig_path)) : "${path.cwd}/kubeconfig"
}

## Importing SSH pvt key to access bastion and EKS nodes

data "tls_public_key" "domino" {
  private_key_openssh = file(var.ssh_pvt_key_path)
}

resource "aws_key_pair" "domino" {
  key_name   = var.deploy_id
  public_key = trimspace(data.tls_public_key.domino.public_key_openssh)
}

module "storage" {
  source                       = "./submodules/storage"
  deploy_id                    = var.deploy_id
  efs_access_point_path        = var.efs_access_point_path
  s3_force_destroy_on_deletion = var.s3_force_destroy_on_deletion
  vpc_id                       = local.vpc_id
  subnets                      = local.private_subnets
}

module "network" {
  count = var.vpc_id == null ? 1 : 0

  source                    = "./submodules/network"
  deploy_id                 = var.deploy_id
  region                    = var.region
  availability_zones        = local.availability_zones
  public_cidr_network_bits  = var.public_cidr_network_bits
  private_cidr_network_bits = var.private_cidr_network_bits
  base_cidr_block           = var.base_cidr_block
  flow_log_bucket_arn       = module.storage.s3_buckets["monitoring"].arn
}

locals {
  vpc_id          = var.vpc_id != null ? var.vpc_id : module.network[0].vpc_id
  public_subnets  = var.vpc_id != null ? var.public_subnets : module.network[0].public_subnets
  private_subnets = var.vpc_id != null ? var.private_subnets : module.network[0].private_subnets
}

module "bastion" {
  count = var.create_bastion ? 1 : 0

  source                   = "./submodules/bastion"
  deploy_id                = var.deploy_id
  region                   = var.region
  vpc_id                   = local.vpc_id
  ssh_pvt_key_path         = aws_key_pair.domino.key_name
  bastion_public_subnet_id = local.public_subnets[0]
  bastion_ami_id           = var.bastion_ami_id
}

module "eks" {
  source                    = "./submodules/eks"
  deploy_id                 = var.deploy_id
  region                    = var.region
  k8s_version               = var.k8s_version
  vpc_id                    = local.vpc_id
  private_subnets           = local.private_subnets
  ssh_pvt_key_path          = aws_key_pair.domino.key_name
  bastion_security_group_id = try(module.bastion[0].security_group_id, "")
  create_bastion_sg         = var.create_bastion
  kubeconfig_path           = local.kubeconfig_path
  default_node_groups       = var.default_node_groups
  additional_node_groups    = var.additional_node_groups
  node_iam_policies         = [module.storage.s3_policy]
  efs_security_group        = module.storage.efs_security_group
}

data "aws_iam_role" "eks_master_roles" {
  for_each = var.create_bastion ? toset(var.eks_master_role_names) : []
  name     = each.key
}

module "k8s_setup" {
  count                = var.create_bastion ? 1 : 0
  source               = "./submodules/k8s"
  ssh_pvt_key_path     = abspath(local.ssh_pvt_key_path)
  bastion_user         = local.bastion_user
  bastion_public_ip    = try(module.bastion[0].public_ip, "")
  k8s_cluster_endpoint = module.eks.cluster_endpoint
  eks_node_role_arns   = [for r in module.eks.eks_node_roles : r.arn]
  eks_master_role_arns = [for r in concat(values(data.aws_iam_role.eks_master_roles), module.eks.eks_master_roles) : r.arn]
  kubeconfig_path      = local.kubeconfig_path
  depends_on = [
    module.eks,
    module.bastion
  ]
}
