variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "storage_info" {
  description = "Storage info."
  type        = any
}

variable "eks_info" {
  description = <<EOF
    cluster = {
      arn               = EKS Cluster arn.
      security_group_id = EKS Cluster security group id.
      endpoint          = EKS Cluster API endpoint.
      roles             = Default IAM Roles associated with the EKS cluster. {
        name = string
        arn = string
      }
      custom_roles      = Custom IAM Roles associated with the EKS cluster. {
        rolearn  = string
        username = string
        groups   = list(string)
      }
      oidc = {
        arn = OIDC provider ARN.
        url = OIDC provider url.
      }
      irsa = {
        namespace_service_accounts = List of ns sa.
      }
    }
    nodes = {
      security_group_id = EKS Nodes security group id.
      roles = IAM Roles associated with the EKS Nodes.{
        name = string
        arn  = string
      }
    }
    kubeconfig = Kubeconfig details.{
      path       = string
      extra_args = string
    }
  EOF
  type = object({
    cluster = object({
      arn               = string
      security_group_id = string
      endpoint          = string
      roles = list(object({
        name = string
        arn  = string
      }))
      custom_roles = list(object({
        rolearn  = string
        username = string
        groups   = list(string)
      }))
      oidc = object({
        arn = string
        url = string
      })
      irsa = object({
        namespace_service_accounts = list(string)
      })
    })
    nodes = object({
      security_group_id = string
      roles = list(object({
        name = string
        arn  = string
      }))
    })
    kubeconfig = object({
      path       = string
      extra_args = string
    })
  })
}
