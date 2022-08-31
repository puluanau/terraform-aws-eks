variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  default     = "domino-eks-example"
}


variable "region" {
  type        = string
  description = "AWS region for the deployment"
}


variable "tags" {
  type        = map(string)
  description = "Deployment tags."
  default = {
    deploy_id        = "domino-eks-example"
    deploy_tag       = "domino-eks-example"
    deploy_type      = "terraform-aws-eks"
    domino-deploy-id = "domino-eks-example"
  }
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
  default     = "1.23"
}
