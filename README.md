# Green-Earth 🌍

Green-Earth is a **smart static website** project built with a simple and reliable stack:

- **Backend**: Flask (Python)  
- **Frontend**: Static HTML, CSS, and JavaScript  
- **Infrastructure**: Hosted on AWS, provisioned with Terraform  

---

## Getting Started

### Prerequisites
- Python 3.x  
- Terraform  
- AWS CLI (configured)

### Architecture

![Architecture Diagram](documentation/diagram.svg)

### Solution Components
- **Network Layer**
  - VPC with public/private subnets across multiple AZs
  - Internet Gateway for public access
  - NAT Gateway for private subnet outbound traffic
  - Route tables controlling traffic flow between tiers
- **Compute Layer**
  - Auto Scaling Group: EC2 instances in private subnets, CPU-based scaling policies (Scale up at >70% CPU & Scale down at <20% CPU)
  - Application Load Balancer: Public-facing HTTP listener, Health checks on /health endpoint, Routes to ASG via target group
- **Security**
  - IAM roles: EC2 instance profile (SSM + CloudWatch access), RDS enhanced monitoring role
  - Security Groups: ALB (HTTP ingress only), Web (HTTP/SSH from ALB), RDS (PostgreSQL from web-server tier)
- **Data Layer**
  - RDS PostgreSQL: Multi-AZ deployment, CloudWatch logging for PostgreSQL
- **Monitoring & Operations**
  - CloudWatch Dashboard: ALB metrics (response time, requests), EC2 metrics (CPU, network)
  - Alarms: ALB 5XX errors, High response time (>1s), CPU utilization thresholds
  - SNS for alert notifications
