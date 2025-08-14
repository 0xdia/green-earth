resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "lb-ipconfig"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  name            = "${var.prefix}-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "${var.prefix}-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = local.http_protocol
  request_path        = "/health.html"
  port                = 9090
  number_of_probes    = 2
  interval_in_seconds = 60
  probe_threshold     = 10

  # TODO: potentially depends on lb_rule to fix destroy issue
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "${var.prefix}-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol                       = local.tcp_protocol
  frontend_port                  = 80
  backend_port                   = 9090
}

resource "azurerm_lb_rule" "lb_rule_api" {
  name                           = "${var.prefix}-rule-api"
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  # probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol      = local.tcp_protocol
  frontend_port = 5000
  backend_port  = 5000
}
