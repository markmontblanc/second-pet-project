
# Створення двох ECR repositories для зберігання backend_rds та backend_redis
resource "aws_ecr_repository" "private_repo_redis" {
  name                 = "petp_redis_repo_${terraform.workspace}"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  tags = {
    Name = "Repository for redis image in ${terraform.workspace}"
  }
}

resource "aws_ecr_repository" "private_repo_rds" {
  name                 = "petp_rds_repo_${terraform.workspace}"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  tags = {
    Name = "Repository for rds image in ${terraform.workspace}"
  }
}

