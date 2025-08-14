output "db_server" {
  value     = azurerm_postgresql_flexible_server.db_server
  sensitive = true
}

output "database" {
  value = azurerm_postgresql_flexible_server_database.database
}


