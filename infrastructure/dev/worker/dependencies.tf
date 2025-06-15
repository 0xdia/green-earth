data "terraform_remote_state" "ground_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstracc"
    container_name       = "drupal-terraform-state"
    key                  = "terraform-ground.tfstate"
  }
}

data "terraform_remote_state" "database_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstracc"
    container_name       = "drupal-terraform-state"
    key                  = "terraform-database.tfstate"
  }
}
