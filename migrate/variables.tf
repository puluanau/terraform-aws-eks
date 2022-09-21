variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  default     = "chibipug25155"
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
  default     = "1.21"
}

variable "public_subnets" {
  default     = [
      {
          name = "chibipug25155-PublicSubnet-us-west-2a-1"
          cidr_block = "10.0.0.0/27"
          zone = "us-west-2a"
          zone_id = "usw2-az1"
          type = "public"
      },
      {
          name = "chibipug25155-PublicSubnet-us-west-2b-2"
          cidr_block = "10.0.0.32/27"
          zone = "us-west-2b"
          zone_id = "usw2-az2"
          type = "public"
      },
      {
          name = "chibipug25155-PublicSubnet-us-west-2c-3"
          cidr_block = "10.0.0.64/27"
          zone = "us-west-2c"
          zone_id = "usw2-az3"
          type = "public"
      }
  ]
}

variable "private_subnets" {
  default     = [
      {
          name = "chibipug25155-PrivateSubnet-us-west-2a-1"
          cidr_block = "10.0.32.0/19"
          zone = "us-west-2a"
          zone_id = "usw2-az1"
          type = "private"
      },
      {
          name = "chibipug25155-PrivateSubnet-us-west-2b-2"
          cidr_block = "10.0.64.0/19"
          zone = "us-west-2b"
          zone_id = "usw2-az2"
          type = "private"
      },
      {
          name = "chibipug25155-PrivateSubnet-us-west-2c-3"
          cidr_block = "10.0.96.0/19"
          zone = "us-west-2c"
          zone_id = "usw2-az3"
          type = "private"
      }
  ]
}
