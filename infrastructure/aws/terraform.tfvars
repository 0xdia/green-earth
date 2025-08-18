# AWS Configuration
aws_region = "eu-central-1"

# Project Configuration
project_name = "eco-webapp"
environment  = "production"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
# public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# Compute Configuration
instance_type    = "t2.micro"
min_size         = 1
max_size         = 5
desired_capacity = 1

# Database Configuration
db_instance_class = "db.t3.micro"
db_name           = "ecowebapp"
db_username       = "admin"
db_password       = "YourSecurePassword123!" # Change this!

# Security Configuration
allowed_cidr_blocks = ["0.0.0.0/0"] # Restrict this for production!
