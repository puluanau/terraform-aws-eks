# terraform-aws-eks

## Create terraform remote state bucket
* Authenticate with aws, make sure that environment variables: `AWS_REGION`, `AWS_ACCESS_KEY_ID` ,`AWS_SECRET_ACCESS_KEY` are set. If your account has MFA set up you will also need `AWS_SESSION_TOKEN`.

### Prerequisites
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* jq (Optional, it parses the api response)

#### 1. Create Bucket(if you already have a bucket just set the `AWS_TERRAFORM_REMOTE_STATE_BUCKET` to its name, and skip this step):
```bash
export AWS_ACCOUNT="$(aws sts get-caller-identity | jq -r .Account)"
export AWS_TERRAFORM_REMOTE_STATE_BUCKET="domino-terraform-rs-${AWS_ACCOUNT}-${AWS_REGION}"

aws s3api create-bucket \
    --bucket "${AWS_TERRAFORM_REMOTE_STATE_BUCKET}" \
    --region ${AWS_REGION} \
    --create-bucket-configuration LocationConstraint="${AWS_REGION}" | jq .
```

#### Verify bucket exists

```bash
aws s3api head-bucket --bucket "${AWS_TERRAFORM_REMOTE_STATE_BUCKET}"
```
You should NOT see an error.

## 2. Initialize the terraform remote-state

```bash
### Set the deploy id. This will be used later as well.
export TF_VAR_deploy_id="mh-tf-test"  ## <-- Feel free to rename.
terraform init \
    -backend-config="bucket=${AWS_TERRAFORM_REMOTE_STATE_BUCKET}" \
    -backend-config="key=domino-eks/${TF_VAR_deploy_id}" \
    -backend-config="region=${AWS_REGION}"

```



## If you need to delete the bucket

```bash

aws s3 rb s3://"${AWS_TERRAFORM_REMOTE_STATE_BUCKET}" --force
```

# Terraform-docs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.22.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./submodules/bastion | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ./submodules/eks | n/a |
| <a name="module_k8s_setup"></a> [k8s\_setup](#module\_k8s\_setup) | ./submodules/k8s | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./submodules/network | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./submodules/storage | n/a |
| <a name="module_subnets_cidr"></a> [subnets\_cidr](#module\_subnets\_cidr) | ./submodules/subnets-cidr | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.domino](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_sensitive_file.pvt_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [tls_private_key.domino](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of Availibility zones to distribute the deployment, EKS needs at least 2,https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html. | `list(string)` | `[]` | no |
| <a name="input_base_cidr_block"></a> [base\_cidr\_block](#input\_base\_cidr\_block) | CIDR block to serve the main private and public subnets. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Create bastion toggle. | `bool` | `false` | no |
| <a name="input_deploy_id"></a> [deploy\_id](#input\_deploy\_id) | Domino Deployment ID. | `string` | `"domino-eks"` | no |
| <a name="input_efs_access_point_path"></a> [efs\_access\_point\_path](#input\_efs\_access\_point\_path) | Filesystem path for efs. | `string` | `"/domino"` | no |
| <a name="input_eks_master_role_names"></a> [eks\_master\_role\_names](#input\_eks\_master\_role\_names) | IAM role names to be added as masters in eks. | `list(string)` | `[]` | no |
| <a name="input_enable_route53_iam_policy"></a> [enable\_route53\_iam\_policy](#input\_enable\_route53\_iam\_policy) | Enable route53 IAM policy toggle. | `bool` | `false` | no |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | EKS cluster k8s version. | `string` | `"1.22"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | EKS managed node groups definition. | `map(map(any))` | <pre>{<br>  "compute": {<br>    "desired": 1,<br>    "instance_type": "m5.2xlarge",<br>    "max": 10,<br>    "min": 0<br>  },<br>  "gpu": {<br>    "desired": 1,<br>    "instance_type": "g4dn.xlarge",<br>    "max": 10,<br>    "min": 0<br>  },<br>  "platform": {<br>    "desired": 1,<br>    "instance_type": "m5.4xlarge",<br>    "max": 10,<br>    "min": 0<br>  }<br>}</pre> | no |
| <a name="input_number_of_azs"></a> [number\_of\_azs](#input\_number\_of\_azs) | Number of AZ to distribute the deployment, EKS needs at least 2. | `number` | `3` | no |
| <a name="input_private_cidr_network_bits"></a> [private\_cidr\_network\_bits](#input\_private\_cidr\_network\_bits) | Number of network bits to allocate to the public subnet. i.e /19 -> 8,190 IPs. | `number` | `19` | no |
| <a name="input_public_cidr_network_bits"></a> [public\_cidr\_network\_bits](#input\_public\_cidr\_network\_bits) | Number of network bits to allocate to the public subnet. i.e /27 -> 30 IPs. | `number` | `27` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the deployment | `string` | n/a | yes |
| <a name="input_route53_hosted_zone"></a> [route53\_hosted\_zone](#input\_route53\_hosted\_zone) | AWS Route53 Hosted zone. | `string` | n/a | yes |
| <a name="input_ssh_pvt_key_name"></a> [ssh\_pvt\_key\_name](#input\_ssh\_pvt\_key\_name) | ssh private key filename. | `string` | `"domino.pem"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Deployment tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for bringing your own vpc, will bypass creation of such. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_id"></a> [deploy\_id](#output\_deploy\_id) | Deployment ID. |
| <a name="output_efs_filesystem_id"></a> [efs\_filesystem\_id](#output\_efs\_filesystem\_id) | EFS volume handle <filesystem id id>::<accesspoint id> |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Domino instance URL. |
| <a name="output_k8s_tunnel_command"></a> [k8s\_tunnel\_command](#output\_k8s\_tunnel\_command) | Command to run the k8s tunnel mallory. |
| <a name="output_region"></a> [region](#output\_region) | Deployment region. |
| <a name="output_ssh_bastion_command"></a> [ssh\_bastion\_command](#output\_ssh\_bastion\_command) | Command to ssh into the bastion host |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
