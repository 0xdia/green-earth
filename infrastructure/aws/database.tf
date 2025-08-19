resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  engine         = "postgres"
  engine_version = "17.4"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:00-Sun:05:00"

  multi_az            = true
  skip_final_snapshot = false
  # Removed timestamp to prevent recreation
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot"

  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = false

  # Optional: Enable PostgreSQL logs
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # PostgreSQL parameters
  parameter_group_name = aws_db_parameter_group.postgres.name

  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.project_name}-postgres17"
  family = "postgres17"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name        = "${var.project_name}-postgres-params"
    Environment = var.environment
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-rds-monitoring-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# SSM Parameters (unchanged)
resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${var.project_name}/db/endpoint"
  type  = "String"
  value = aws_db_instance.main.endpoint

  tags = {
    Name        = "${var.project_name}-db-endpoint"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project_name}/db/name"
  type  = "String"
  value = var.db_name

  tags = {
    Name        = "${var.project_name}-db-name"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.project_name}/db/username"
  type  = "String"
  value = var.db_username

  tags = {
    Name        = "${var.project_name}-db-username"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db/password"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Name        = "${var.project_name}-db-password"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_instance" {
  name  = "/${var.project_name}/db/instance"
  type  = "String"
  value = "${var.project_name}-db"

  tags = {
    Name        = "${var.project_name}-db-instance"
    Environment = var.environment
  }
}
