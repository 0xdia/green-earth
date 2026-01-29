module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat           = true
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = module.networking.vpc_cidr
}

module "database" {
  source = "../../modules/database"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  db_security_group_id    = module.security.rds_sg_id
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_instance_class       = var.db_instance_class
  allocated_storage       = var.allocated_storage
  multi_az                = false # to save cost
  backup_retention_period = var.backup_retention_period
  monitoring_role_arn     = var.monitoring_role_arn
  tags                    = var.tags
}

module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  web_sg_id          = module.security.web_sg_id
  instance_profile   = module.security.instance_profile
  instance_type      = var.instance_type
  min_size           = 1
  max_size           = 2
  desired_capacity   = 1

  user_data = templatefile("${path.module}/user_data.sh", {
    db_endpoint = module.database.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    aws_region  = var.aws_region
  })
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name   = var.project_name
  environment    = var.environment
  alb_arn_suffix = module.compute.alb_arn_suffix
  asg_name       = module.compute.asg_name
  sns_topic_arn  = var.sns_topic_arn
  tags           = var.tags
}
