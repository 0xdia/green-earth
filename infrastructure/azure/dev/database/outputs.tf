output "db_server" {
  value     = module.database.db_server
  sensitive = true
}

output "database" {
  value = module.database.database
}
