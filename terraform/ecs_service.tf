

resource "aws_ecs_service" "redis_service" {
  name            = "redis-service"
  cluster         = aws_ecs_cluster.petp_cluster.id
  task_definition = aws_ecs_task_definition.redis_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_a.id]
    security_groups = [aws_security_group.redis_sg.id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "ECS"  # Або "CODE_DEPLOY", якщо використовуєте
  }

  depends_on = [aws_lb.my_alb]
}

resource "aws_ecs_service" "backend_rds_service" {
  name            = "backend-rds-service"
  cluster         = aws_ecs_cluster.petp_cluster.id
  task_definition = aws_ecs_task_definition.backend_rds_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_a.id]
    security_groups = [aws_security_group.backend_rds_sg.id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "ECS"  # Або "CODE_DEPLOY", якщо використовуєте
  }

  depends_on = [aws_lb.my_alb]
}


