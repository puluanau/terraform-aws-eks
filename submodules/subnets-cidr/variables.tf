variable "availability_zones" {
  type = map(string)

  default = {
    "us-west-2a" = "usw2-az1",
    "us-west-2b" = "usw2-az2",
    "us-west-2c" = "usw2-az3"
  }

  description = "Map of availability zone: names - >  ids where the subnets will be created"
  validation {
    condition = (
      length(compact(keys(var.availability_zones))) == length(compact(keys(var.availability_zones))) &&
      length(compact(values(var.availability_zones))) == length(compact(values(var.availability_zones))) &&
      length(distinct(keys(var.availability_zones))) == length(keys(var.availability_zones)) &&
      length(distinct(values(var.availability_zones))) == length(values(var.availability_zones))
    )
    error_message = "Argument availability_zones must not contain any duplicate/empty key or value."
  }
}

# variable "pod_base_cidr_block" {
#   type        = string
#   default     = "100.164.0.0/16"
#   description = "CIDR block to serve the pods subnets"
#   validation {
#     condition = (
#       try(cidrhost(var.pod_base_cidr_block, 0), null) == regex("^(.*)/", var.pod_base_cidr_block)[0] &&
#       try(cidrnetmask(var.pod_base_cidr_block), null) == "255.255.0.0"
#     )
#     error_message = "Argument pod_base_cidr_block  must be a valid CIDR block."
#   }
# }

variable "base_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block to serve the main private and public subnets"
  validation {
    condition = (
      try(cidrhost(var.base_cidr_block, 0), null) == regex("^(.*)/", var.base_cidr_block)[0] &&
      try(cidrnetmask(var.base_cidr_block), null) == "255.255.0.0"
    )
    error_message = "Argument base_cidr_block must be a valid CIDR block."
  }
}

variable "public_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the public subnet. i.e /27 -> 30 IPs"
  default     = 27
}

variable "private_cidr_network_bits" {
  type        = number
  description = "Number of network bits to allocate to the public subnet. i.e /19 -> 8,190 IPs"
  default     = 19
}

variable "subnet_name_prefix" {
  type        = string
  description = "String to serve as a prefix/identifier when naming the subnets"

  validation {
    condition     = can(regex("^[a-z-0-9]{3,32}$", var.subnet_name_prefix))
    error_message = "Argument deploy_id must: start with a letter, contain lowercase alphanumeric characters(can contain hyphens[-]) with length between 3 and 32 characters."
  }
}
