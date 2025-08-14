resource "azurerm_subnet" "worker_subnet" {
  name                 = "${var.prefix}-worker-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "${var.prefix}-lb-pubip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb_nat_pool" "ssh_nat_pool" {
  name                           = "${var.prefix}-ssh-nat-pool"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  protocol                       = local.tcp_protocol
  backend_port                   = local.ssh_port
  frontend_port_start            = 60000
  frontend_port_end              = 60050
}
