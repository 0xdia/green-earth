resource "azurerm_postgresql_flexible_server" "db_server" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.engine_version
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  zone                   = "1"
  delegated_subnet_id    = azurerm_subnet.db_subnet.id
  private_dns_zone_id    = var.dns_zone_id

  sku_name = "B_Standard_B1ms"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azuread_client_config.current.tenant_id
  }

  public_network_access_enabled = false # TODO: toggle it later
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name      = "AllowScaleSet"
  server_id = azurerm_postgresql_flexible_server.db_server.id
  # TODO: Allow backend machines only
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.db_server.id
}

