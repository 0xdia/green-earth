provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstracc"
    container_name       = "drupal-terraform-state"
    key                  = "terraform-ground.tfstate"
    use_azuread_auth     = true # ensure state locking
    snapshot             = true
  }
}

module "ground" {
  source = "../../modules/ground"

  prefix         = "drupal"
  location       = "France Central"
  address_space  = ["10.0.0.0/16"]
  ssh_pub_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDX9TNtJomcdDL1LlDo5YKKRsqsQVbCYSXWzgibH8Gynrr2Q/X0siQbq0ch0AbRH/3qG6noXZyzNXsMvI2T78eEiZiSfas/kQ+23PmSYJ00ORdPTgJrPP1o7oo9qQf4kD89qK6I01tQJID99ue2iCP/CB3yMKseV0qhpta8MCA3zGRUFnVC0P5yBUY/35P9mnhPuADWp/0/QoBI8nYLsOAoip1SNkOLDSr3t/8awvJ/lH6kpD/DBBP/B46KnM2Zh6T8FpUp52UvvzVPB/XfrSdqibEuwzSHSOdwvmPdFXaAgOhINKNuSeP+C7AO9CY47UAwLSkm5ZyS7os+HmY26DiPuO+j6HDvtnJH7W/JmPFSkihNUDZmNVDGANUgeNOzGOmn/NBRYL7dkdI5mKJfWeG/pwIZtZQwVbYXzSqUHMlmRZiDvUPS5DtRw3RgcLbFrntAujYdPFQYDREmAJjLBm0PuWhSUnLUTRJocFZSp0QJGnJktPd9KeEJ0wD/4/810PE= generated-by-azure"
  key_vault_name = "drupal-kv-${random_string.suffix.result}"
  tenant_id      = data.azuread_client_config.current.tenant_id
  object_id      = data.azuread_client_config.current.object_id
}

resource "random_string" "suffix" {
  length  = 5
  special = false
}
