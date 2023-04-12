variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "irsa_enabled" {
  description = "IAM Roles for Service Accounts enabled."
  type        = bool
  default     = false
}

variable "irsa_iam_policy" {
  description = "IAM Policy ARN for IRSA Role."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster's EKS provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS cluster's EKS provider."
  type        = string
}

variable "compute_namespace" {
  description = "EKS cluster compute namespace"
  type        = string
}

variable "platform_namespace" {
  description = "EKS cluster platform namespace"
  type        = string
}
