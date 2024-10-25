# Створення групи безпеки для ElastiCache
resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = aws_vpc.my_petp_vpc.id

  # Вхідні правила (ingress)
  ingress {
    from_port   = 6379 # Порт Redis за замовчуванням
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_a.cidr_block, aws_subnet.private_subnet_b.cidr_block] # Доступ лише з приватних підмереж
  }

  # Вихідні правила (egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elasticache-sg-${terraform.workspace}"
  }
}

# ElastiCache Redis кластер
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"   # Економний варіант для тестування або малих навантажень
  num_cache_nodes      = 1                  # Для production можна збільшити кількість вузлів
  parameter_group_name = "default.redis7" # Використовуємо дефолтну параметр групу
  port                 = 6379               # Redis порт
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.elasticache_sg.id] # Прикріплюємо Security Group

  tags = {
    Name = "my-redis-cluster-${terraform.workspace}"
  }
}

# Підмережна група для ElastiCache
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "redis-subnet-group-${terraform.workspace}"
  }
}


# Output the Redis primary endpoint
output "redis_primary_endpoint" {
  value = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address
}