# Outputs for the ECR repositories
output "ecr_repository_redis" {
  value = aws_ecr_repository.private_repo_redis.repository_url
}

output "ecr_repository_rds" {
  value = aws_ecr_repository.private_repo_rds.repository_url
}

# Output the DNS names of the load balancers
output "alb_rds_dns" {
  value = aws_lb.my_alb1.dns_name
}

output "alb_redis_dns" {
  value = aws_lb.my_alb2.dns_name
}

