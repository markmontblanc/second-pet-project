


# Defining Redis ECS Task Definition
resource "aws_ecs_task_definition" "redis_task" {
  family                   = "redis-task-${terraform.workspace}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_rolee.arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "654654200977.dkr.ecr.eu-north-1.amazonaws.com/petp_redis_repo_default:latest"
      essential = true
      environment = [
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address  # Підставляємо Redis endpoint
        },
        {
          name  = "REDIS_PORT"
          value = "6379"
        },
        {
          name  = "REDIS_DB"
          value = "0"
        }
      ]
      portMappings = [
        {
          containerPort = 8002
          hostPort      = 8002
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Defining backend RDS ECS Task Definition
resource "aws_ecs_task_definition" "backend_rds_task" {
  family                   = "backend-rds-task-${terraform.workspace}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_rolee.arn

  container_definitions = jsonencode([
    {
      name      = "backend_rds"
      image     = "654654200977.dkr.ecr.eu-north-1.amazonaws.com/petp_rds_repo_default:latest"
      essential = true
      environment = [
        {
          name  = "DB_NAME"
          value = "marko_db"
        },
        {
          name  = "DB_USER"
          value = "postgres"
        },
        {
          name  = "DB_PASSWORD"
          value = "adminadmin76!"
        },
        {
          name  = "DB_HOST"
          value = "my-petp-db-default.ctsskiqw2d3n.eu-north-1.rds.amazonaws.com"
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address  # Підставляємо Redis endpoint
        },
        {
          name  = "REDIS_PORT"
          value = "6379"
        },
        {
          name  = "REDIS_DB"
          value = "0"
        }
      ]
      portMappings = [
        {
          containerPort = 8001
          hostPort      = 8001
          protocol      = "tcp"
        }
      ]
    }
  ])
}


