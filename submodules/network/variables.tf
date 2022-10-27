variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"
  default     = ""

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "region" {
  type        = string
  description = "AWS region for the deployment"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zone names where the subnets will be created"
  validation {
    condition = (
      length(compact(distinct(var.availability_zones))) == length(var.availability_zones)
    )
    error_message = "Argument availability_zones must not contain any duplicate/empty values."
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "list of cidrs for the public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "list of cidrs for the private subnets"
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
    error_message = "Argument cidr must be a valid CIDR block."
  }
}

## This is an object in order to be used as a conditional in count, due to https://github.com/hashicorp/terraform/issues/26755
variable "flow_log_bucket_arn" {
  type        = object({ arn = string })
  description = "Bucket for vpc flow logging"
  default     = null
}

variable "add_cluster_tag_to_subnet" {
  type        = bool
  description = "Toggle k8s cluster tag on subnet"
  default     = true
}
