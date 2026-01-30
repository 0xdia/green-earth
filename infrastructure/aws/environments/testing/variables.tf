variable "aws_region" { default = "eu-west-3" }
variable "project_name" { default = "eco-webapp" }
variable "environment" { default = "testing" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "availability_zones" { default = ["eu-west-3a", "eu-west-3b"] }
variable "public_subnet_cidrs" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnet_cidrs" { default = ["10.0.10.0/24", "10.0.20.0/24"] }
variable "instance_type" { default = "t3.small" }
variable "db_name" { default = "ecodb" }
variable "db_username" { default = "ecoadmin" }
variable "db_password" {
  type      = string
  sensitive = true
  default   = ""
}
variable "db_instance_class" { default = "db.t3.micro" }
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "backup_retention_period" {
  type    = number
  default = 7
}
variable "monitoring_role_arn" {
  type    = string
  default = ""
}
variable "sns_topic_arn" {
  type    = string
  default = ""
}
variable "tags" {
  type = map(string)
  default = {
    Project     = "eco-webapp"
    Environment = "testing"
    ManagedBy   = "Terraform"
  }
}
variable "multi_az_enabled" {
  type    = bool
  default = false
}
variable "create_read_replica" {
  type    = bool
  default = false
}
variable "read_replica_instance_class" {
  type    = string
  default = ""
}
