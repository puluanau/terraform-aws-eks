variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  default     = "domino-eks"
  nullable    = false

  validation {
    condition     = length(var.deploy_id) >= 3 && length(var.deploy_id) <= 32 && can(regex("^[a-z]([-a-z0-9]*[a-z0-9])$", var.deploy_id))
    error_message = <<EOT
      Variable deploy_id must:
      1. Length must be between 3 and 32 characters.
      2. Start with a letter.
      3. End with a letter or digit.
      4. Contain lowercase Alphanumeric characters and hyphens.
    EOT
  }
}

variable "region" {
  type        = string
  description = "AWS region for the deployment"
}

variable "update_kubeconfig_extra_args" {
  type        = string
  description = "Optional extra args when generating kubeconfig"
  default     = ""
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
  description = <<EOT
    List of Availibility zones to distribute the deployment, EKS needs at least 2,https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html.
    Note that setting this variable bypasses validation of the status of the zones data 'aws_availability_zones' 'available'.
    Caller is responsible for validating status of these zones.
  EOT

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) >= 2
    error_message = "EKS deployment needs at least 2 zones."
  }
  default = []
}

variable "route53_hosted_zone_name" {
  type        = string
  description = "Optional hosted zone for External DNSone."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Deployment tags."
  default     = {}
}

variable "k8s_version" {
  type        = string
  description = "EKS cluster k8s version."
  default     = "1.24"
}

variable "public_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the public subnet. i.e /27 -> 32 IPs."
  default     = 27
}

variable "private_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the private subnet. i.e /19 -> 8,192 IPs."
  default     = 19
}

variable "pod_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the private subnet. i.e /19 -> 8,192 IPs."
  default     = 19
}

variable "default_node_groups" {
  description = "EKS managed node groups definition."
  type = object(
    {
      compute = object(
        {
          ami                  = optional(string, null)
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
          gpu    = optional(bool, null)
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
          ami                  = optional(string, null)
          bootstrap_extra_args = optional(string, "")
          instance_types       = optional(list(string), ["m5.4xlarge"])
          spot                 = optional(bool, false)
          min_per_az           = optional(number, 1)
          max_per_az           = optional(number, 10)
          desired_per_az       = optional(number, 1)
          labels = optional(map(string), {
            "dominodatalab.com/node-pool" = "platform"
          })
          taints = optional(list(object({ key = string, value = optional(string), effect = string })), [])
          tags   = optional(map(string), {})
          gpu    = optional(bool, null)
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
          ami                  = optional(string, null)
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
          taints = optional(list(object({ key = string, value = optional(string), effect = string })), [
            { key = "nvidia.com/gpu", value = "true", effect = "NO_SCHEDULE" }
          ])
          tags = optional(map(string), {})
          gpu  = optional(bool, null)
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
    ami                  = optional(string, null)
    bootstrap_extra_args = optional(string, "")
    instance_types       = list(string)
    spot                 = optional(bool, false)
    min_per_az           = number
    max_per_az           = number
    desired_per_az       = number
    labels               = map(string)
    taints               = optional(list(object({ key = string, value = optional(string), effect = string })), [])
    tags                 = optional(map(string), {})
    gpu                  = optional(bool, null)
    volume = object({
      size = string
      type = string
    })
  }))
  default = {}
}

variable "cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC."
  validation {
    condition = (
      try(cidrhost(var.cidr, 0), null) == regex("^(.*)/", var.cidr)[0] &&
      try(cidrnetmask(var.cidr), null) == "255.255.0.0"
    )
    error_message = "Argument base_cidr_block must be a valid CIDR block."
  }
}

variable "pod_cidr" {
  type        = string
  default     = "100.64.0.0/16"
  description = "The IPv4 CIDR block for the VPC."
  validation {
    condition = (
      try(cidrhost(var.pod_cidr, 0), null) == regex("^(.*)/", var.pod_cidr)[0] &&
      try(cidrnetmask(var.pod_cidr), null) == "255.255.0.0"
    )
    error_message = "Argument base_cidr_block must be a valid CIDR block."
  }
}

variable "use_pod_cidr" {
  type        = bool
  description = "Use additional pod CIDR range (ie 100.64.0.0/16) for pod/service networking"
  default     = true
}

variable "eks_master_role_names" {
  type        = list(string)
  description = "IAM role names to be added as masters in eks."
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "Optional VPC ID, it will bypass creation of such, public_subnets and private_subnets are also required."
  default     = null
}

variable "public_subnets" {
  type        = list(string)
  description = "Optional list of public subnet ids"
  default     = null
}

variable "private_subnets" {
  type        = list(string)
  description = "Optional list of private subnet ids"
  default     = null
}

variable "pod_subnets" {
  type        = list(string)
  description = "Optional list of pod subnet ids"
  default     = null
}

variable "bastion" {
  type = object({
    ami                      = optional(string, null) # default will use the latest 'amazon_linux_2' ami
    instance_type            = optional(string, "t2.micro")
    authorized_ssh_ip_ranges = optional(list(string), ["0.0.0.0/0"])
  })
  description = "if specifed, a bastion is created with the specified details"
  default     = null
}

variable "efs_access_point_path" {
  type        = string
  description = "Filesystem path for efs."
  default     = "/domino"
}

variable "ssh_pvt_key_path" {
  type        = string
  description = "SSH private key filepath."
  validation {
    condition     = fileexists(var.ssh_pvt_key_path)
    error_message = "Private key does not exist. Please provide the right path or generate a key with the following command: ssh-keygen -q -P '' -t rsa -b 4096 -m PEM -f domino.pem"
  }
}

variable "s3_force_destroy_on_deletion" {
  description = "Toogle to allow recursive deletion of all objects in the s3 buckets. if 'false' terraform will NOT be able to delete non-empty buckets"
  type        = bool
  default     = false
}

variable "ecr_force_destroy_on_deletion" {
  description = "Toogle to allow recursive deletion of all objects in the ECR repositories. if 'false' terraform will NOT be able to delete non-empty repositories"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "if use_kms is set, use the specified KMS key"
  type        = string
  default     = null
  validation {
    condition     = var.kms_key_id == null ? true : length(var.kms_key_id) > 0
    error_message = "KMS key ID must be null or set to a non-empty string"
  }
}

variable "use_kms" {
  description = "if set, use either the specified KMS key or a Domino-generated one"
  type        = bool
  default     = false
}

variable "kubeconfig_path" {
  description = "fully qualified path name to write the kubeconfig file"
  type        = string
  default     = ""
}

variable "create_efs_backup_vault" {
  description = "Create backup vault for EFS toggle."
  type        = bool
  default     = true
}

variable "efs_backup_vault_force_destroy" {
  description = "Toggle to allow automatic destruction of all backups when destroying."
  type        = bool
  default     = false
}

variable "efs_backup_schedule" {
  type        = string
  description = "Cron-style schedule for EFS backup vault (default: once a day at 12pm)"
  default     = "0 12 * * ? *"
}

variable "efs_backup_cold_storage_after" {
  type        = number
  description = "Move backup data to cold storage after this many days"
  default     = 35
}

variable "efs_backup_delete_after" {
  type        = number
  description = "Delete backup data after this many days"
  default     = 125
}

variable "eks_custom_role_maps" {
  type        = list(object({ rolearn = string, username = string, groups = list(string) }))
  description = "Custom role maps for aws auth configmap"
  default     = []
}
