


# Outputs for the ECR repositories
output "ecr_repository_redis" {
  value = aws_ecr_repository.private_repo_redis.repository_url
}

output "ecr_repository_rds" {
  value = aws_ecr_repository.private_repo_rds.repository_url
}

# Виведення DNS імені для ALB
output "alb_dns" {
  value = aws_lb.my_alb.dns_name
  description = "DNS ім'я Application Load Balancer"
}





