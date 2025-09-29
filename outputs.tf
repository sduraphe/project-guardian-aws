# outputs.tf

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "main_s3_bucket_name" {
  value = aws_s3_bucket.main_bucket.bucket
}

output "quarantine_s3_bucket_name" {
  value = aws_s3_bucket.quarantine_bucket.bucket
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "application_url" {
  description = "The public URL of the application load balancer"
  value       = "http://${aws_lb.main.dns_name}"
}