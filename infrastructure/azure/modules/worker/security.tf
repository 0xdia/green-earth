resource "azurerm_network_security_group" "worker_nsg" {
  name                = "${var.prefix}-worker-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "Allow_PING"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }

  # TODO: Allow Health Probes and HTTP traffic seperately
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = local.tcp_protocol
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*" // 9090
    destination_address_prefix = "*"
  }

  security_rule { # Does not require NAT
    name                       = "Allow_SSH"
    priority                   = 1030
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = local.tcp_protocol
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }

  # TODO: add deny all rule
}

# this resource if enough to create a role for the managed identity ?
# A potential: this resource depends on the existence of the scale set,
# so when the user data script runs, this role is not already created.
# Data could not therefore be fetched ? Or not ?
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  server_name         = var.db_server_name
  resource_group_name = var.resource_group_name
  tenant_id           = azurerm_linux_virtual_machine_scale_set.scale_set.identity[0].tenant_id
  object_id           = azurerm_linux_virtual_machine_scale_set.scale_set.identity[0].principal_id
  principal_name      = azurerm_linux_virtual_machine_scale_set.scale_set.name
  principal_type      = "ServicePrincipal"
}
