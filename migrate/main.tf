module "domino_eks" {
  source                       = "../../terraform-aws-eks"
  deploy_id                    = var.deploy_id
  region                       = var.region
  number_of_azs                = 3
  k8s_version                  = var.k8s_version
  route53_hosted_zone_name     = "infra-team-sandbox.domino.tech"
  eks_master_role_names        = ["okta-poweruser", "okta-fulladmin"]
  s3_force_destroy_on_deletion = true
  create_bastion               = true
  ssh_pvt_key_path             = "domino-test.pem"
  enable_vpc_endpoints_s3      = false
  tags                         = var.tags
  public_subnets               = var.public_subnets
  private_subnets              = var.private_subnets
}
