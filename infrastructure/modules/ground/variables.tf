variable "prefix" {
  description = "value to prefix all resources with"
  type        = string
  default     = "example"
}

variable "location" {
  description = "location to deploy resources in"
  type        = string
}

variable "address_space" {
  description = "address space for the virtual network"
  type        = list(string)
}

variable "key_vault_name" {
  description = "name of the key vault"
  type        = string
}

variable "ssh_pub_key" {
  description = "ssh public key"
  type        = string
}

variable "tenant_id" {
  type = string
}

variable "object_id" {
  type = string
}

locals {}
