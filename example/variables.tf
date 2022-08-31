variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  default     = "mhtfeks"
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
    deploy_id        = "domino-eks"
    deploy_tag       = "domino-eks"
    deploy_type      = "terraform-aws-eks"
    domino-deploy-id = "domino-eks"
  }
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
  default     = "1.23"
}
