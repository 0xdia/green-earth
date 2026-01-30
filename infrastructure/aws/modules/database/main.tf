# variables
variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_security_group_id" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "multi_az" { type = bool }
variable "backup_retention_period" { type = number }
variable "monitoring_role_arn" { type = string }
variable "tags" { type = map(string) }
variable "create_read_replica" { type = bool }
variable "read_replica_instance_class" { type = string }

# main
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.project_name}-${var.environment}" })
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}"

  engine         = "postgres"
  engine_version = "17.4"
  instance_class = var.db_instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:00-Sun:05:00"

  multi_az                  = var.multi_az
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final"

  monitoring_interval = 0
  monitoring_role_arn = var.monitoring_role_arn

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}" })
}

resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier          = "${var.project_name}-${var.environment}-replica"
  replicate_source_db = aws_db_instance.main.arn

  instance_class    = var.read_replica_instance_class != "" ? var.read_replica_instance_class : var.db_instance_class
  storage_encrypted = true

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 0
  backup_window           = null
  maintenance_window      = "Sun:05:00-Sun:06:00"

  multi_az = false

  monitoring_interval = 0
  monitoring_role_arn = var.monitoring_role_arn

  skip_final_snapshot = true

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-replica" })
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.project_name}-${var.environment}-postgres17"
  family = "postgres17"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = var.tags
}

# outputs
output "db_endpoint" { value = aws_db_instance.main.endpoint }
output "db_address" { value = aws_db_instance.main.address }
output "db_port" { value = aws_db_instance.main.port }
output "db_identifier" { value = aws_db_instance.main.identifier }
output "db_subnet_group_name" { value = aws_db_subnet_group.main.name }
output "read_replica_endpoint" { value = var.create_read_replica ? aws_db_instance.read_replica[0].endpoint : null }
output "read_replica_address" { value = var.create_read_replica ? aws_db_instance.read_replica[0].address : null }
