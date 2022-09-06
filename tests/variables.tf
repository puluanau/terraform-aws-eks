variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  default     = "domino-eks-test"
}


variable "region" {
  type        = string
  description = "AWS region for the deployment"
  default     = "us-west-2"
}


variable "tags" {
  type        = map(string)
  description = "Deployment tags."
  default = {
    deploy_id        = "domino-eks-test"
    deploy_tag       = "domino-eks-test"
    deploy_type      = "terraform-aws-eks"
    domino-deploy-id = "domino-eks-test"
  }
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
  default     = "1.23"
}
