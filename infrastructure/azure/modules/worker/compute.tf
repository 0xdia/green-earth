resource "azurerm_linux_virtual_machine_scale_set" "scale_set" {
  name                = "${var.prefix}-scale-set"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.scale_set_size
  priority            = "Spot"
  eviction_policy     = "Deallocate"
  admin_username      = var.admin_username
  user_data           = base64encode(templatefile("${path.module}/custom_data.sh", {}))
  automatic_instance_repair {
    enabled      = true
    action       = "Replace"
    grace_period = "PT10M"
  }
  health_probe_id = azurerm_lb_probe.lb_probe.id
  upgrade_mode    = "Automatic"

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_pub_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "${var.prefix}-vm-scale-set-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.worker_nsg.id
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.worker_subnet.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.lb_backend_pool.id
      ]
      load_balancer_inbound_nat_rules_ids = [
        azurerm_lb_nat_pool.ssh_nat_pool.id
      ]
    }
  }

  boot_diagnostics {}
  # TODO: fix scaling out/recovery, if a VM gets deleted, the backend pool should add another VM
  # Is it because Health Probe is not set in this configuration?
}
