<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_id"></a> [deploy\_id](#input\_deploy\_id) | Domino Deployment ID | `string` | n/a | yes |
| <a name="input_eks_info"></a> [eks\_info](#input\_eks\_info) | cluster = {<br>      arn               = EKS Cluster arn.<br>      security\_group\_id = EKS Cluster security group id.<br>      endpoint          = EKS Cluster API endpoint.<br>      roles             = Default IAM Roles associated with the EKS cluster. {<br>        name = string<br>        arn = string<br>      }<br>      custom\_roles      = Custom IAM Roles associated with the EKS cluster. {<br>        rolearn  = string<br>        username = string<br>        groups   = list(string)<br>      }<br>      oidc = {<br>        arn = OIDC provider ARN.<br>        url = OIDC provider url.<br>      }<br>      irsa = {<br>        namespace\_service\_accounts = List of ns sa.<br>      }<br>    }<br>    nodes = {<br>      security\_group\_id = EKS Nodes security group id.<br>      roles = IAM Roles associated with the EKS Nodes.{<br>        name = string<br>        arn  = string<br>      }<br>    }<br>    kubeconfig = Kubeconfig details.{<br>      path       = string<br>      extra\_args = string<br>    } | <pre>object({<br>    cluster = object({<br>      arn               = string<br>      security_group_id = string<br>      endpoint          = string<br>      roles = list(object({<br>        name = string<br>        arn  = string<br>      }))<br>      custom_roles = list(object({<br>        rolearn  = string<br>        username = string<br>        groups   = list(string)<br>      }))<br>      oidc = object({<br>        arn = string<br>        url = string<br>      })<br>      irsa = object({<br>        namespace_service_accounts = list(string)<br>      })<br>    })<br>    nodes = object({<br>      security_group_id = string<br>      roles = list(object({<br>        name = string<br>        arn  = string<br>      }))<br>    })<br>    kubeconfig = object({<br>      path       = string<br>      extra_args = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_storage_info"></a> [storage\_info](#input\_storage\_info) | Storage info. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_roles"></a> [roles](#output\_roles) | Map of IRSA IAM Role Name/ARN. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
