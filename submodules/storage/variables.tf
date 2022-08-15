variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}


variable "efs_access_point_path" {
  type        = string
  description = "Filesystem path for efs."
  default     = "/domino"

}

variable "tags" {
  type        = map(string)
  description = "Deployment tags."
}

variable "subnets" {
  type = list(object({
    name       = string
    id         = string
    cidr_block = string
  }))
  description = "List of subnet ids to create EFS mount targets"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string

}

variable "s3_force_destroy_toggle" {
  description = "Toogle to allow recursive deletion of all objects in the s3 buckets. if 'false' terraform will NOT be able to delete non-empty buckets"
  type        = string
  default     = "false"
}
