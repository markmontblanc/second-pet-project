resource "aws_security_group" "private_inst_sg" {
  vpc_id = aws_vpc.my_petp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]  # Access from bastion host
  }

  # Ingress rule to allow RDS traffic from the ALB
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    security_groups = [
    aws_security_group.my_alb1_sg.id,  # Allows access from ALB1 (RDS)
    ]
  }

  # Ingress rule to allow Redis traffic from the ALB
  ingress {
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    security_groups = [
    aws_security_group.my_alb2_sg.id   # Allows access from ALB2 (Redis)
    ]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_inst_sg"
  }
}




# SG для бастіона
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.my_petp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Доступ до SSH з будь-якої адреси
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}