# vpc.tf

# This module creates a best-practice VPC, subnets, and routing.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = "project-guardian-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# This gets the available AZs in the current region
data "aws_availability_zones" "available" {}

# Security group for our Application Load Balancer (ALB)
# It allows inbound web traffic from anywhere.
resource "aws_security_group" "alb_sg" {
  name        = "project-guardian-alb-sg"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for our ECS Application
# It ONLY allows inbound traffic from our ALB's security group.
resource "aws_security_group" "ecs_sg" {
  name        = "project-guardian-ecs-sg"
  description = "Allow traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    # CHANGE THIS BLOCK
    from_port       = 5000 # <-- From 80 to 5000
    to_port         = 5000 # <-- From 80 to 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}