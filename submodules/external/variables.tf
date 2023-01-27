variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID"
  default     = ""

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.deploy_id))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
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

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnets IDs to create EFS mount targets"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "docdb" {
  description = "DocumentDB"
  type        = map(any)
  default = {
    master_username         = "mongo"
    maintenance_window      = "sat:06:00-sat:08:00"
    backup_window           = "04:00-05:45"
    backup_retention_period = 30
    deletion_protection     = false # ???
    instance_class          = "db.t4g.medium"
  }
}

variable "elasticache" {
  description = "ElastiCache"
  type        = map(any)
  default = {
    maintenance_window       = "sat:06:00-sun:00:00"
    snapshot_window          = "04:00-05:45"
    snapshot_retention_limit = 0
    parameter_group_name     = "default.redis7"
    engine_version           = "7.0"
    node_type                = "cache.m4.large"
  }
}

variable "opensearch" {
  description = "OpenSearch"
  type        = map(any)
  default = {
    engine_version = "Elasticsearch_7.10"
    instance_type  = "m6g.large.search"
    username       = "opensearch"
    volume_size    = 100
  }
}


variable "rds" {
  description = "RDS"
  type        = map(any)
  default = {
    engine_version        = "14"
    instance_class        = "db.m6g.xlarge"
    allocated_storage     = 50
    max_allocated_storage = 150
    maintenance_window    = "sat:06:00-sat:08:00"
    deletion_protection   = false # TODO
    username              = "rds"
  }
}
