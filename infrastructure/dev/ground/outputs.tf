output "resource_group" {
  value = module.ground.resource_group
}

output "key_vault" {
  value = module.ground.key_vault
}

output "dns_zone" {
  value = module.ground.dns_zone
}

output "ssh_public_key" {
  value = module.ground.ssh_public_key
}

output "vnet" {
  value = module.ground.vnet
}
