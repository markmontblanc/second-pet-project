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

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_ec2_private_ip" {
  value = aws_instance.private_inst.private_ip
}