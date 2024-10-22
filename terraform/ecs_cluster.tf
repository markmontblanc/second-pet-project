resource "aws_ecs_cluster" "redis_cluster" {
  name = "redis-cluster-${terraform.workspace}"

  tags = {
    Name = "redis-cluster-${terraform.workspace}"
  }
}
