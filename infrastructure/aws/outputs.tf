output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "postgres_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

