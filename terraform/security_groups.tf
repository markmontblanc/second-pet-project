resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Allow inbound traffic to Redis from private subnets"
  vpc_id      = aws_vpc.my_petp_vpc.id

  # Вхідні правила (ingress)
  ingress {
    description      = "Allow access from private subnets"
    from_port        = 8002
    to_port          = 8002
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.private_subnet_a.cidr_block, aws_subnet.private_subnet_b.cidr_block] # Дозволяємо з приватних підмереж
  }

  # Вихідні правила (egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Дозволяємо весь вихідний трафік
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg-${terraform.workspace}"
  }
}



resource "aws_security_group" "backend_rds_sg" {
  name        = "backend-rds-sg"
  description = "Allow inbound traffic to backend RDS service"
  vpc_id      = aws_vpc.my_petp_vpc.id

  # Вхідні правила (ingress)
  ingress {
    description      = "Allow HTTP from ALB"
    from_port        = 8001
    to_port          = 8001
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]       # Відкритий доступ через ALB
  }

  ingress {
    description      = "Allow access from private subnets"
    from_port        = 8002
    to_port          = 8002
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.private_subnet_a.cidr_block, aws_subnet.private_subnet_b.cidr_block]  # Доступ до Redis з приватних підмереж
  }

  # Вихідні правила (egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-rds-sg-${terraform.workspace}"
  }
}






