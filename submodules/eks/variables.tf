variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "update_kubeconfig_extra_args" {
  type        = string
  description = "Optional extra args when generating kubeconfig"
  default     = ""
}

variable "region" {
  type        = string
  description = "AWS region for the deployment"
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
}

variable "default_node_groups" {
  description = "EKS managed node groups definition."
  type = object(
    {
      compute = object(
        {
          ami                  = optional(string)
          bootstrap_extra_args = optional(string, "")
          instance_types       = optional(list(string), ["m5.2xlarge"])
          spot                 = optional(bool, false)
          min_per_az           = optional(number, 0)
          max_per_az           = optional(number, 10)
          desired_per_az       = optional(number, 1)
          labels = optional(map(string), {
            "dominodatalab.com/node-pool" = "default"
          })
          taints = optional(list(object({ key = string, value = optional(string), effect = string })), [])
          tags   = optional(map(string), {})
          volume = optional(object(
            {
              size = optional(number, 100)
              type = optional(string, "gp3")
            }),
            {
              size = 100
              type = "gp3"
            }
          )
      }),
      platform = object(
        {
          ami                  = optional(string)
          bootstrap_extra_args = optional(string, "")
          instance_types       = optional(list(string), ["m5.4xlarge"])
          spot                 = optional(bool, false)
          min_per_az           = optional(number, 0)
          max_per_az           = optional(number, 10)
          desired_per_az       = optional(number, 1)
          labels = optional(map(string), {
            "dominodatalab.com/node-pool" = "platform"
          })
          taints = optional(list(object({ key = string, value = optional(string), effect = string })), [])
          tags   = optional(map(string), {})
          volume = optional(object(
            {
              size = optional(number, 100)
              type = optional(string, "gp3")
            }),
            {
              size = 100
              type = "gp3"
            }
          )
      }),
      gpu = object(
        {
          ami                  = optional(string)
          bootstrap_extra_args = optional(string, "")
          instance_types       = optional(list(string), ["g4dn.xlarge"])
          spot                 = optional(bool, false)
          min_per_az           = optional(number, 0)
          max_per_az           = optional(number, 10)
          desired_per_az       = optional(number, 0)
          labels = optional(map(string), {
            "dominodatalab.com/node-pool" = "default-gpu"
            "nvidia.com/gpu"              = true
          })
          taints = optional(list(object({ key = string, value = optional(string), effect = string })), [])
          tags   = optional(map(string), {})
          volume = optional(object(
            {
              size = optional(number, 100)
              type = optional(string, "gp3")
            }),
            {
              size = 100
              type = "gp3"
            }
          )
      })
  })
  default = {
    compute  = {}
    platform = {}
    gpu      = {}
  }
}

variable "additional_node_groups" {
  description = "Additional EKS managed node groups definition."
  type = map(object({
    ami                  = optional(string)
    bootstrap_extra_args = optional(string, "")
    instance_types       = list(string)
    spot                 = optional(bool, false)
    min_per_az           = number
    max_per_az           = number
    desired_per_az       = number
    labels               = map(string)
    taints               = optional(list(object({ key = string, value = optional(string), effect = string })), [])
    tags                 = optional(map(string), {})
    volume = object({
      size = string
      type = string
    })
  }))
  default = {}
}

variable "kubeconfig_path" {
  type        = string
  description = "Kubeconfig file path."
  default     = "kubeconfig"
}

variable "private_subnets" {
  description = "List of Private subnets IDs and AZ"
  type        = list(object({ subnet_id = string, az = string }))
  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "EKS deployment needs at least 2 subnets. https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html."
  }
}

variable "pod_subnets" {
  description = "List of POD subnets IDs and AZ"
  type        = list(object({ subnet_id = string, az = string }))
  validation {
    condition     = length(var.pod_subnets) != 1
    error_message = "EKS deployment needs at least 2 subnets. https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "ssh_key_pair_name" {
  type        = string
  description = "SSH key pair name."
}

variable "bastion_security_group_id" {
  type        = string
  description = "Bastion security group id."
  default     = ""
}

variable "eks_cluster_addons" {
  type        = list(string)
  description = "EKS cluster addons. vpc-cni is installed separately."
  default     = ["kube-proxy", "coredns"]
}

variable "create_bastion_sg" {
  description = "Create bastion access rules toggle."
  type        = bool
  default     = false
}

variable "node_iam_policies" {
  description = "Additional IAM Policy Arns for Nodes"
  type        = list(string)
}

variable "efs_security_group" {
  description = "Security Group ID for EFS"
  type        = string
}

variable "external_security_group" {
  description = "Security Group ID for external services"
  type        = string
}

variable "eks_master_role_names" {
  type        = list(string)
  description = "IAM role names to be added as masters in eks"
  default     = []
}

variable "ssh_pvt_key_path" {
  type        = string
  description = "Path to SSH private key"
  default     = ""
}

variable "bastion_user" {
  type        = string
  description = "Username for bastion instance"
  default     = ""
}

variable "bastion_public_ip" {
  type        = string
  description = "Public IP of bastion instance"
  default     = ""
}
