# ---------------------
# VPC
# ---------------------
resource "aws_vpc" "mwaa_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.tag
  }
}

# ---------------------
# Internet Gateway
# ---------------------
resource "aws_internet_gateway" "mwaa_igw" {
  vpc_id = aws_vpc.mwaa_vpc.id

  tags = {
    Name = var.tag
  }
}

# ---------------------
# Elastic IP for NAT Gateway
# ---------------------
resource "aws_eip" "mwaa_nat_eip" {
  tags = {
    Name = "${var.tag}-nat-eip"
  }
}

# ---------------------
# Public Subnets
# ---------------------
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.mwaa_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag}-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.mwaa_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag}-public-2"
  }
}

# ---------------------
# Private Subnets
# ---------------------
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.mwaa_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.tag}-private-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.mwaa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.tag}-private-2"
  }
}

# ---------------------
# NAT Gateway
# ---------------------
resource "aws_nat_gateway" "mwaa_nat" {
  allocation_id = aws_eip.mwaa_nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = var.tag
  }
}

# ---------------------
# Route Table for Public Subnets
# ---------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.mwaa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mwaa_igw.id
  }

  tags = {
    Name = "${var.tag}-public"
  }
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# ---------------------
# Route Table for Private Subnets (via NAT)
# ---------------------
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.mwaa_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mwaa_nat.id
  }

  tags = {
    Name = "${var.tag}-private"
  }
}

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# ---------------------
# Security Group for MWAA
# ---------------------
resource "aws_security_group" "mwaa_sg" {
  name        = "${var.tag}-mwaa-sg"
  description = "Allow HTTPS access to MWAA UI"
  vpc_id      = aws_vpc.mwaa_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.personal_public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag}-mwaa-sg"
  }
}
