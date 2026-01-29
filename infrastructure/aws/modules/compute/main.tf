# variables
variable "project_name" {}
variable "environment" {}
variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "alb_sg_id" {}
variable "web_sg_id" {}
variable "instance_profile" {}
variable "instance_type" { default = "t3.small" }
variable "ami_id" { default = "" }
variable "key_name" { default = "" }
variable "min_size" { default = 2 }
variable "max_size" { default = 6 }
variable "desired_capacity" { default = 2 }
variable "user_data" {}

# main
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-${var.environment}"
  vpc_id   = var.vpc_id
  port     = 5000
  protocol = "HTTP"

  health_check {
    enabled = true
    path    = "/health"
    port    = "5000"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_launch_template" "web" {
  name_prefix            = "${var.project_name}-${var.environment}-"
  image_id               = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.key_name != "" ? var.key_name : null

  iam_instance_profile { name = var.instance_profile }
  user_data = base64encode(var.user_data)
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = { AutoScalingGroupName = aws_autoscaling_group.web.name }
}

# outputs
output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_arn_suffix" { value = aws_lb.main.arn_suffix }
output "asg_name" { value = aws_autoscaling_group.web.name }
