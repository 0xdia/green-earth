resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = "${var.prefix}-key"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = var.ssh_pub_key
}
