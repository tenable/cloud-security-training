resource "aws_vpc" "vpcep-demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpcep-demo-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpcep-demo.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "vpcep-demo-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpcep-demo.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "vpcep-demo-private-subnet"
  }
}

resource "aws_security_group" "public" {
  name_prefix = "public-"
  vpc_id      = aws_vpc.vpcep-demo.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-security-group"
  }
}

resource "aws_security_group" "private" {
  name_prefix = "private-"
  vpc_id      = aws_vpc.vpcep-demo.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-security-group"
  }
}

resource "aws_internet_gateway" "vpcep-demo" {
  vpc_id = aws_vpc.vpcep-demo.id
  tags = {
    Name = "vpcep-demo-igw"
  }
} 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpcep-demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcep-demo.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
} 