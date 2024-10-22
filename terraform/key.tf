# Генерація приватного ключа
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "petp_keypair" {
  key_name   = "petp_keypair-${terraform.workspace}"  # Додаємо ім'я середовища
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = "petp_keypair-${terraform.workspace}"  # Ім'я ключа на основі середовища
}