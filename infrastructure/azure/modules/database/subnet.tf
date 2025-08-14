resource "azurerm_subnet" "db_subnet" {
  name                 = "${var.prefix}-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes


  delegation {
    name = "db-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }
}

