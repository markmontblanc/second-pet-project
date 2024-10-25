
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