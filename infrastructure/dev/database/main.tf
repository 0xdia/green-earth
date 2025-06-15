provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstracc"
    container_name       = "drupal-terraform-state"
    key                  = "terraform-database.tfstate"
    use_azuread_auth     = true # ensure state locking
    snapshot             = true
  }
}

module "database" {
  source = "../../modules/database"

  prefix              = "drupal"
  location            = "France Central"
  resource_group_name = data.terraform_remote_state.ground_state.outputs.resource_group.name
  server_name         = "drupal-db-server"
  admin_login         = "drupaldbadmin"
  admin_password      = random_password.initial_db_password.result
  engine_version      = "16"
  db_name             = "drupaldb"
  dns_zone_id         = data.terraform_remote_state.ground_state.outputs.dns_zone.id
  vnet_name           = data.terraform_remote_state.ground_state.outputs.vnet.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_key_vault_secret" "db_password" {
  name            = "drupal-db-admin-password"
  key_vault_id    = data.terraform_remote_state.ground_state.outputs.key_vault.id
  value           = random_password.initial_db_password.result
  expiration_date = timeadd(timestamp(), "24h")

  lifecycle {
    ignore_changes = [expiration_date, value]
  }
}

resource "random_password" "initial_db_password" {
  length           = 32
  lower            = true
  upper            = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
}
