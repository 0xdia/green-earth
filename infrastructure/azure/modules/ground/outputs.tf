output "key_vault" {
  value = azurerm_key_vault.key_vault
}

output "dns_zone" {
  value = azurerm_private_dns_zone.dns_zone
}

output "resource_group" {
  value = azurerm_resource_group.rg
}

output "ssh_public_key" {
  value = azurerm_ssh_public_key.ssh_public_key
}

output "vnet" {
  value = azurerm_virtual_network.vnet
}
