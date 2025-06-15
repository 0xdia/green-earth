provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstracc"
    container_name       = "drupal-terraform-state"
    key                  = "terraform-worker.tfstate"
    use_azuread_auth     = true # ensure state locking
    snapshot             = true
  }
}

module "worker" {
  source = "../../modules/worker"

  prefix              = "drupal"
  location            = "France Central"
  address_prefixes    = ["10.0.2.0/24"]
  ssh_pub_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDX9TNtJomcdDL1LlDo5YKKRsqsQVbCYSXWzgibH8Gynrr2Q/X0siQbq0ch0AbRH/3qG6noXZyzNXsMvI2T78eEiZiSfas/kQ+23PmSYJ00ORdPTgJrPP1o7oo9qQf4kD89qK6I01tQJID99ue2iCP/CB3yMKseV0qhpta8MCA3zGRUFnVC0P5yBUY/35P9mnhPuADWp/0/QoBI8nYLsOAoip1SNkOLDSr3t/8awvJ/lH6kpD/DBBP/B46KnM2Zh6T8FpUp52UvvzVPB/XfrSdqibEuwzSHSOdwvmPdFXaAgOhINKNuSeP+C7AO9CY47UAwLSkm5ZyS7os+HmY26DiPuO+j6HDvtnJH7W/JmPFSkihNUDZmNVDGANUgeNOzGOmn/NBRYL7dkdI5mKJfWeG/pwIZtZQwVbYXzSqUHMlmRZiDvUPS5DtRw3RgcLbFrntAujYdPFQYDREmAJjLBm0PuWhSUnLUTRJocFZSp0QJGnJktPd9KeEJ0wD/4/810PE= generated-by-azure"
  resource_group_name = data.terraform_remote_state.ground_state.outputs.resource_group.name
  vnet_name           = data.terraform_remote_state.ground_state.outputs.vnet.name
  sku                 = "Standard_F1"
  admin_username      = "drupal-admin"
  db_server_name      = data.terraform_remote_state.database_state.outputs.db_server.name
  scale_set_size      = 1
}
