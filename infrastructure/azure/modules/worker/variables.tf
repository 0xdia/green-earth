variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "location" {
  type = string
}

variable "sku" {
  type = string
}

variable "scale_set_size" {
  type = number
}

variable "admin_username" {
  type = string
}

variable "ssh_pub_key" {
  type = string
}

variable "db_server_name" {
  type = string
}

locals {
  ssh_port      = 22
  tcp_protocol  = "Tcp"
  http_protocol = "Http"
}
