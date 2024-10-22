resource "aws_ecs_service" "redis_service" {
  name            = "redis-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.redis_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet.id]  # Приватні підмережі для Fargate
    security_groups = [aws_security_group.private_inst_sg.id]  # Security Group для Redis
    assign_public_ip = false  # Тому що використовуємо приватну підмережу
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.redis_tg.arn
    container_name   = "redis"
    container_port   = 6379
  }

  depends_on = [
    aws_lb_target_group.redis_tg,
    aws_lb_listener.frontend_listener
  ]

  tags = {
    Name = "redis-service-${terraform.workspace}"
  }
}
