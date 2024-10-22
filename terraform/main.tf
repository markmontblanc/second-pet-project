

# Subnet для RDS, RDS, SG для RDS 
# RDS Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group-${terraform.workspace}"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "my-db-subnet-group-${terraform.workspace}"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "my_postgres_db" {
  identifier             = "my-petp-db-${terraform.workspace}"
  engine                 = "postgres"
  engine_version         = "11.22"
  instance_class         = "db.t3.micro"
  allocated_storage       = 20
  username               = "postgres"
  password               = "adminadmin76!"
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.my_rds_sg.id]

  db_name              = "marko_db"

  skip_final_snapshot     = true
  multi_az                = false

  tags = {
    Name = "my-petp-db-${terraform.workspace}"
  }
}

# RDS Security Group
resource "aws_security_group" "my_rds_sg" {
  name        = "my-rds-sg-${terraform.workspace}"
  description = "Security group for RDS instance (${terraform.workspace})"
  vpc_id      = aws_vpc.my_petp_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]  # Access from private subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-rds-sg-${terraform.workspace}"
  }
}





# Security Group for ALB1 (for RDS service)
resource "aws_security_group" "my_alb1_sg" {
  name        = "alb1-sg-${terraform.workspace}"
  description = "Allow HTTP/HTTPS traffic to ALB1 (${terraform.workspace})"
  vpc_id      = aws_vpc.my_petp_vpc.id

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
    Name = "alb1-sg-${terraform.workspace}"
  }
}

# Security Group for ALB2 (for Redis service)
resource "aws_security_group" "my_alb2_sg" {
  name        = "alb2-sg-${terraform.workspace}"
  description = "Allow HTTP/HTTPS traffic to ALB2 (${terraform.workspace})"
  vpc_id      = aws_vpc.my_petp_vpc.id

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
    Name = "alb2-sg-${terraform.workspace}"
  }
}




# ALB1 for RDS Service
resource "aws_lb" "my_alb1" {
  name               = "my-alb1-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_alb1_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  enable_deletion_protection = false

  tags = {
    Name = "my-alb1-${terraform.workspace}"
  }
}

# ALB2 for Redis Service
resource "aws_lb" "my_alb2" {
  name               = "my-alb2-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_alb2_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  enable_deletion_protection = false

  tags = {
    Name = "my-alb2-${terraform.workspace}"
  }
}


# Step 6: Create dynamic config.json using templatefile
resource "local_file" "updated_config" {
  content  = templatefile("${path.module}/config_template.json", {
    alb_rds_dns   = aws_lb.my_alb1.dns_name,
    alb_redis_dns = aws_lb.my_alb2.dns_name
  })
  filename = "${path.module}/updated_config.json"
}

# Step 7: Upload updated config.json to the S3 bucket
resource "aws_s3_object" "upload_config" {
  bucket = aws_s3_bucket.example.id
  key    = "config.json" # File path in the S3 bucket
  source = local_file.updated_config.filename
}

resource "aws_s3_object" "upload_index" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"  # Name of the new file in the S3 bucket
  source = "../frontend/templates/index.html"  # Path to the local file you want to upload
}



# Step 9: Upload Docker Compose file to the S3 bucket
resource "aws_s3_object" "upload_docker_compose" {
  bucket = aws_s3_bucket.example.id
  key    = "docker-compose.yaml"  # Name of the Docker Compose file in the S3 bucket
  source = "../docker-compose.yaml"  # Path to your local Docker Compose file
}





# Target Group for RDS Service (ALB1)
resource "aws_lb_target_group" "rds_target_group" {
  name     = "rds-target-group-${terraform.workspace}"
  port     = 8001
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_petp_vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/test_connection/rds"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "rds-target-group-${terraform.workspace}"
  }
}

# Target Group for Redis Service (ALB2)
resource "aws_lb_target_group" "redis_target_group" {
  name     = "redis-target-group-${terraform.workspace}"
  port     = 8002
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_petp_vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/test_connection/redis"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "redis-target-group-${terraform.workspace}"
  }
}




# Прив'язка EC2 до Target Group для RDS
resource "aws_lb_target_group_attachment" "rds_attachment" {
  target_group_arn = aws_lb_target_group.rds_target_group.arn
  target_id        = aws_instance.private_inst.id  # ID EC2 для RDS
  port             = 8001
}

# Прив'язка EC2 до Target Group для Redis
resource "aws_lb_target_group_attachment" "redis_attachment" {
  target_group_arn = aws_lb_target_group.redis_target_group.arn
  target_id        = aws_instance.private_inst.id  # ID EC2 для Redis
  port             = 8002
}

# Listeners for ALB1 (RDS Service)
resource "aws_lb_listener" "alb1_http_listener" {
  load_balancer_arn = aws_lb.my_alb1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rds_target_group.arn
  }
}



# Listeners for ALB2 (Redis Service)
resource "aws_lb_listener" "alb2_http_listener" {
  load_balancer_arn = aws_lb.my_alb2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_target_group.arn
  }
}










