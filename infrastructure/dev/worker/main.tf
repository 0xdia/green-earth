provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstracc"
    container_name       = "green-earth-terraform-state"
    key                  = "terraform-worker.tfstate"
    use_azuread_auth     = true # ensure state locking
    snapshot             = true
  }
}

module "worker" {
  source = "../../modules/worker"

  prefix              = "greenearth"
  location            = "France Central"
  address_prefixes    = ["10.0.2.0/24"]
  ssh_pub_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZUQz3Fxpllp74XpGMGt0Bc0DF4EeR36q5bTJnRuBQAErM4FlRqvI1gRknHw45a3wT/zjPkcxeIpReTHTst+fcydyHndJRf3oFrTBz4RCPi6p7DbJzjavXlYhzs5pGpjoEi4Kna3W/Zxi6AgvRjxgiVwm2AJtTBoW6ImrQILdEKziCVnao398ZPFMACdk1AA7+6Tzp68nY9ET4eNvBP4ep+Ry2hp18hNMHmaM8LWAFX8w0EdKW/JFME3Nqi1JVxYV9NWP1xaQ3BRfRWPEmnFtpIYRap+s/gLSSV0E2O84CIJjMNyE4xZrPA1RuVQNUB5UYVroo7pShLmKS7NuKoOIToOVwnWAM/+fTUXwQlc2OcPAbbtCwIC/xLO9xiFxKQ9NkygGJYFSMaWQkSfjw7ZHvIqgJeKmubQal/UobddkEIMe+3gWUPSJYzRgxFmWZxEI39GyI295dF4VBN1fjYS+K2YgVuxsELhluZADQZiezCilAK3BU4qYsRClrr43Xm4U= generated-by-azure"
  resource_group_name = data.terraform_remote_state.ground_state.outputs.resource_group.name
  vnet_name           = data.terraform_remote_state.ground_state.outputs.vnet.name
  sku                 = "Standard_F1"
  admin_username      = "green-earth-admin"
  db_server_name      = data.terraform_remote_state.database_state.outputs.db_server.name
  scale_set_size      = 1
}
