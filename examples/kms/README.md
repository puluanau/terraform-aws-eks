# EKS with kms_key encryption enabled.

### Provide full path for existing ssh key:  `ssh_pvt_key_path`
### Otherwise generate using:
```bash
ssh-keygen -q -P '' -t rsa -b 4096 -m PEM -f domino.pem
```
### Enabling kms encryption in the module.
```hcl
  kms = {
    enabled = true # Enables kms encryption.
    key_id = <kms.key_id> # If provided, the key will be used. Otherwise the module will generate and use a kms_key.
  }
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_domino_eks"></a> [domino\_eks](#module\_domino\_eks) | ./../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.kms_key](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region for deployment. | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domino_eks"></a> [domino\_eks](#output\_domino\_eks) | Module domino\_eks output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
