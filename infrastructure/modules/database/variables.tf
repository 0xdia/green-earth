variable "prefix" {
  type = string
}

variable "server_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "admin_login" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "engine_version" {
  type = string
  validation {
    condition     = can(regex("^(11|12|13|14|15|16)$", var.engine_version))
    error_message = "Version must be between 11 and 16"
  }
}

variable "vnet_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "dns_zone_id" {
  type = string
}

locals {}
