resource "aws_vpc" "packet-analyzer-demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "packet-analyzer-demo-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.packet-analyzer-demo.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "packet-analyzer-demo-public-subnet"
  }
}

resource "aws_internet_gateway" "packet-analyzer-demo" {
  vpc_id = aws_vpc.packet-analyzer-demo.id
  tags = {
    Name = "packet-analyzer-demo-igw"
  }
} 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.packet-analyzer-demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.packet-analyzer-demo.id
  }
  tags = {
    Name = "public-route-table-packet-analyzer-demo"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
} 