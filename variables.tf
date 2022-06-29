variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  default     = "domino-eks"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "region" {
  type        = string
  description = "AWS region for the deployment"
}

variable "number_of_azs" {
  type        = number
  description = "Number of AZ to distribute the deployment, EKS needs at least 2."
  default     = 3
  validation {
    condition     = var.number_of_azs >= 2
    error_message = "EKS deployment needs at least 2 zones."
  }
}


variable "availability_zones" {
  type        = list(string)
  description = "List of Availibility zones to distribute the deployment, EKS needs at least 2,https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html."
  default     = []
}


variable "route53_hosted_zone" {
  type        = string
  description = "AWS Route53 Hosted zone."
}

variable "tags" {
  type        = map(string)
  description = "Deployment tags."
  default     = {}
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
  default     = "1.22"
}

variable "public_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the public subnet. i.e /27 -> 30 IPs."
  default     = 27
}

variable "private_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the public subnet. i.e /19 -> 8,190 IPs."
  default     = 19
}

variable "node_groups" {
  type        = map(map(any))
  description = "EKS managed node groups definition."
  default = {
    "compute" = {
      instance_type = "m5.2xlarge"
      min           = 0
      max           = 10
      desired       = 1
    },
    "platform" = {
      instance_type = "m5.4xlarge"
      min           = 0
      max           = 10
      desired       = 1
    },
    "gpu" = {
      instance_type = "g4dn.xlarge"
      min           = 0
      max           = 10
      desired       = 1
    }
  }
}

variable "base_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block to serve the main private and public subnets."
  validation {
    condition = (
      try(cidrhost(var.base_cidr_block, 0), null) == regex("^(.*)/", var.base_cidr_block)[0] &&
      try(cidrnetmask(var.base_cidr_block), null) == "255.255.0.0"
    )
    error_message = "Argument base_cidr_block must be a valid CIDR block."
  }
}

variable "eks_master_role_names" {
  type        = list(string)
  description = "IAM role names to be added as masters in eks."
  default     = []
}

variable "enable_route53_iam_policy" {
  type        = bool
  description = "Enable route53 IAM policy toggle."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for bringing your own vpc, will bypass creation of such."
  default     = ""
}

variable "create_bastion" {
  type        = bool
  description = "Create bastion toggle."
  default     = false
}

variable "efs_access_point_path" {
  type        = string
  description = "Filesystem path for efs."
  default     = "/domino"

}

variable "ssh_pvt_key_name" {
  type        = string
  description = "ssh private key filename."
  default     = "domino.pem"
}
