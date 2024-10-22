resource "aws_vpc" "my_petp_vpc" {
  cidr_block = "10.0.0.0/18"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-petp-vpc-${terraform.workspace}"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "my-nat-eip-${terraform.workspace}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "my-nat-gateway-${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_petp_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "my-public-subnet-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_petp_vpc.id
  tags = {
    Name = "my-internet-gateway-${terraform.workspace}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_petp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "my-public-route-table-${terraform.workspace}"
  }
}

resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_assoc" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_petp_vpc.id
  cidr_block        = "10.0.1.0/24"  # Діапазон для приватної підмережі
  availability_zone = "eu-north-1a"  # Має бути та сама зона доступності

  tags = {
    Name = "my-private-subnet-${terraform.workspace}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_petp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "my-private-route-table-${terraform.workspace}"
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.my_petp_vpc.id
  cidr_block        = "10.0.3.0/24"  # Унікальний CIDR для іншої підмережі
  availability_zone = "eu-north-1a"  # Перша зона доступності

  tags = {
    Name = "my-private-subnet-a-${terraform.workspace}"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.my_petp_vpc.id
  cidr_block        = "10.0.4.0/24"  # Унікальний CIDR блок для приватної підмережі
  availability_zone = "eu-north-1b"  # Друга зона доступності

  tags = {
    Name = "my-private-subnet-b-${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.my_petp_vpc.id
  cidr_block        = "10.0.6.0/24"  # CIDR для першої публічної підмережі
  availability_zone = "eu-north-1a"

  tags = {
    Name = "my-public-subnet-a-${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.my_petp_vpc.id
  cidr_block        = "10.0.8.0/24"  # CIDR для другої публічної підмережі
  availability_zone = "eu-north-1b"

  tags = {
    Name = "my-public-subnet-b-${terraform.workspace}"
  }
}