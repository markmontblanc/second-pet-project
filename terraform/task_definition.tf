resource "aws_ecs_task_definition" "redis_task_definition" {
  family                   = "redis-task-${terraform.workspace}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"  # Вибір процесора
  memory                   = "512"  # Вибір пам'яті

  container_definitions = jsonencode([{
    name  = "redis"
    image = "654654200977.dkr.ecr.eu-north-1.amazonaws.com/petp_redis_repo_test:latest"  # ECR URI для Redis образу
    cpu   = 256
    memory = 512
    essential = true
    portMappings = [{
      containerPort = 6379
      hostPort      = 6379
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/redis"
        "awslogs-region"        = "eu-north-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "redis-task-${terraform.workspace}"
  }
}
