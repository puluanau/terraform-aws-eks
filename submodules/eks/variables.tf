variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "region" {
  type        = string
  description = "AWS region for the deployment"
}

variable "tags" {
  type        = map(string)
  description = "Deployment tags"
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
  default     = "1.22"
}

variable "node_groups" {
  description = "EKS managed node groups definition."
  type = object({
    compute = object({
      ami            = optional(string)
      instance_type  = string
      min_per_az     = number
      max_per_az     = number
      desired_per_az = number
      volume = object({
        size = string
        type = string
      })
    }),
    platform = object({
      ami            = optional(string)
      instance_type  = string
      min_per_az     = number
      max_per_az     = number
      desired_per_az = number
      volume = object({
        size = string
        type = string
      })
    }),
    gpu = object({
      ami            = optional(string)
      instance_type  = string
      min_per_az     = number
      max_per_az     = number
      desired_per_az = number
      volume = object({
        size = string
        type = string
      })
    })
  })
}

variable "kubeconfig_path" {
  type        = string
  description = "Kubeconfig filename."
  default     = "kubeconfig"
}

variable "private_subnets" {
  description = "Private subnets object"
  type = list(object({
    cidr_block = string
    name       = string
    type       = string
    zone       = string
    zone_id    = string
    id         = string
  }))
  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "EKS deployment needs at least 2 subnets. https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "ssh_pvt_key_name" {
  type        = string
  description = "ssh private key filename."
}

variable "route53_hosted_zone_name" {
  type        = string
  description = "Route53 zone"
}

variable "bastion_security_group_id" {
  type        = string
  description = "Bastion security group id."
  default     = ""
}

variable "eks_cluster_addons" {
  type        = list(string)
  description = "EKS cluster addons."
  default     = ["vpc-cni", "kube-proxy", "coredns"]
  # default     = ["vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver"]
}

variable "eks_security_group_rules" {
  type        = map(any)
  description = "EKS security group rules."
  default     = {}
}

variable "create_bastion_sg" {
  type        = bool
  description = "Create bastion access rules toggle."
}

variable "s3_buckets" {
  description = "S3 buckets information that the nodegroups need access to"
  type = list(object({
    bucket_name = string
    arn         = string
  }))

}
