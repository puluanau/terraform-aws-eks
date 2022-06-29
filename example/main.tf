module "domino_eks" {
  source                    = "../../terraform-aws-eks"
  deploy_id                 = "mhtfeks"
  region                    = "us-west-2"
  number_of_azs             = 2
  route53_hosted_zone       = "infra-team-sandbox.domino.tech"
  eks_master_role_names     = ["okta-poweruser", "okta-fulladmin"]
  create_bastion            = true
  enable_route53_iam_policy = true
  tags = {
    deploy_id        = "domino-eks"
    deploy_tag       = "domino-eks"
    deploy_type      = "terraform-aws-eks"
    domino-deploy-id = "domino-eks"
  }
}
