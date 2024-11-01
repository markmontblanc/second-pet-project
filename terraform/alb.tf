

resource "aws_lb" "my_alb" {
  name               = "my-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80 
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_rds_target_group.arn  # Default to backend RDS
  }
}

resource "aws_lb_listener_rule" "my_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.redis_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/test_connection/redis/*"]
    }
  }
}

resource "aws_lb_listener_rule" "rds_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 2

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_rds_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/test_connection/rds/*"]
    }
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80   # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443  # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Додаємо правило ICMP
  ingress {
    from_port   = -1      # Дозволяє всі ICMP трафік
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_sg"
  }
}

resource "aws_lb_target_group" "redis_target_group" {
  name     = "redis-target-group-${terraform.workspace}"
  port     = 8002
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/test_connection/redis"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "backend_rds_target_group" {
  name     = "backend-rds-target-group-${terraform.workspace}"
  port     = 8001
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/test_connection/rds"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

