variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}

variable "region" {
  type        = string
  description = "AWS region for the deployment"
}

variable "tags" {
  type        = map(string)
  description = "Deployment tags"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "ssh_pvt_key_name" {
  type        = string
  description = "ssh private key filename."
}

variable "bastion_public_subnet_id" {
  type        = string
  description = "Public subnet to create bastion host in."
}

variable "bastion_security_group_rules" {
  type = map(any)

  description = "Bastion host security group rules."

  default = {
    bastion_outbound_traffic = {
      description              = "Allow all outbound traffic by default"
      protocol                 = "-1"
      from_port                = "0"
      to_port                  = "0"
      type                     = "egress"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
    bastion_inbound_ssh = {
      description              = "Inbound ssh"
      protocol                 = "-1"
      from_port                = "22"
      to_port                  = "22"
      type                     = "ingress"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
  }

}
