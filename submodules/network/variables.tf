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

variable "base_cidr_block" {
  type        = string
  description = "CIDR block to serve the main private and public subnets"
  validation {
    condition = (
      try(cidrhost(var.base_cidr_block, 0), null) == regex("^(.*)/", var.base_cidr_block)[0] &&
      try(cidrnetmask(var.base_cidr_block), null) == "255.255.0.0"
    )
    error_message = "Argument base_cidr_block must be a valid CIDR block."
  }
}

variable "public_subnets" {
  description = "Public subnets object"
  type = list(object({
    cidr_block = string
    name       = string
    type       = string
    zone       = string
    zone_id    = string
  }))
}

variable "private_subnets" {
  description = "Private subnets object"
  type = list(object({
    cidr_block = string
    name       = string
    type       = string
    zone       = string
    zone_id    = string
  }))
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
  default     = ""
}

variable "monitoring_s3_bucket_arn" {
  type        = string
  description = "Monitoring bucket for vpc flow logging"
}
