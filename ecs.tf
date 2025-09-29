# ecs.tf

# 1. Create the Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "project-guardian-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

# 2. Create a Target Group for the ALB to send traffic to
resource "aws_lb_target_group" "main" {
  name_prefix = "api-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  lifecycle {
    create_before_destroy = true
  }
}

# 3. Create a Listener to forward HTTP traffic on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# 4. Create the ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "project-guardian-cluster"
}

# 5. Create a CloudWatch Log Group for our application's logs
resource "aws_cloudwatch_log_group" "guardian_api_logs" {
  name              = "/ecs/project-guardian-api"
  retention_in_days = 7
}

# --- Task Definition and Service ---

# These data sources get our current account ID and region automatically
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 6. Define the ECS Task Definition (the application blueprint)
resource "aws_ecs_task_definition" "main" {
  family                   = "guardian-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5 GB
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "guardian-api-container"
      # This points to the image our CI pipeline builds and pushes to ECR
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/project-guardian/api:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      # --- NEW SECTION: Pass environment variables to the container ---
      environment = [
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.main_bucket.bucket
        },
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.processing_queue.id # .id provides the URL
        }
      ]
      # --- END NEW SECTION ---
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.guardian_api_logs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# 7. Create the ECS Service to run and manage our task
resource "aws_ecs_service" "main" {
  name            = "guardian-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = 2 # Run two copies for high availability

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "guardian-api-container"
    container_port   = 5000
  }

  # This ensures the service waits for the ALB to be ready
  depends_on = [aws_lb_listener.http]
}
