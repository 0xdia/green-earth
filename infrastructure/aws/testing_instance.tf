# Standalone EC2 instance for testing
resource "aws_instance" "test_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = "eco-webapp-key"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.private[0].id # Use first private subnet
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
  }))

  tags = {
    Name        = "${var.project_name}-test-instance"
    Environment = var.environment
    Purpose     = "Testing"
  }

  # Ensure we have all dependencies created first
  depends_on = [
    aws_db_instance.main,
    aws_ssm_parameter.db_endpoint,
    aws_ssm_parameter.db_name,
    aws_ssm_parameter.db_username,
    aws_ssm_parameter.db_password
  ]
}

# Elastic IP for the test instance (optional, for direct access)
resource "aws_eip" "test_instance" {
  domain   = "vpc"
  instance = aws_instance.test_instance.id

  tags = {
    Name        = "${var.project_name}-test-instance-eip"
    Environment = var.environment
  }
}

# Output the test instance connection details
output "test_instance_public_ip" {
  description = "Public IP of the test instance"
  value       = aws_eip.test_instance.public_ip
}

output "test_instance_private_ip" {
  description = "Private IP of the test instance"
  value       = aws_instance.test_instance.private_ip
}

output "test_instance_ssh_command" {
  description = "SSH command to connect to the test instance"
  value       = "ssh -i eco-webapp-key.pem ec2-user@${aws_eip.test_instance.public_ip}"
}

output "test_instance_ssm_command" {
  description = "AWS SSM command to connect to the test instance"
  value       = "aws ssm start-session --target ${aws_instance.test_instance.id}"
}
