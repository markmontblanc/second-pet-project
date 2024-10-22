# Приватний інстанс
resource "aws_instance" "private_inst" {
  ami           = "ami-0129bfde49ddb0ed6"
  instance_type = var.instance_type  # Залежить від середовища
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = aws_key_pair.petp_keypair.key_name

  tags = {
    Name = "private_instance-${terraform.workspace}"
  }

  security_groups = [aws_security_group.private_inst_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Updating packages..."
    sudo dnf update -y
    echo "Installing Docker..."
    sudo dnf install docker -y
    echo "Starting Docker service..."
    sudo systemctl start docker
    echo "Enabling Docker to start on boot..."
    sudo systemctl enable docker
    echo "Adding user to Docker group..."
    sudo usermod -aG docker ec2-user
    sudo chmod 666 /var/run/docker.sock
    echo "Verifying Docker group membership..."
    groups ec2-user
    su -s $${USER}
    groups ec2-user
    echo "Installing compatibility libraries..."
    sudo dnf install libxcrypt-compat -y
  EOF
}

# Бастіон хост
resource "aws_instance" "bastion" {
  ami                    = "ami-0129bfde49ddb0ed6" # Вкажи свій AMI
  instance_type         = var.instance_type
  associate_public_ip_address = true
  subnet_id             = aws_subnet.public_subnet.id
  key_name              = aws_key_pair.petp_keypair.key_name
  security_groups       = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion Host"
  }
}
