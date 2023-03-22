resource "aws_vpc_endpoint" "vpcep-demo" {
  count = var.create_s3_vpc_endpoint ? 1 : 0 

  vpc_id            = aws_vpc.vpcep-demo.id
  service_name      = "com.amazonaws.us-east-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "route_table_association" {
  count = var.create_s3_vpc_endpoint ? 1 : 0  
  route_table_id   = aws_vpc.vpcep-demo.default_route_table_id
  vpc_endpoint_id  = aws_vpc_endpoint.vpcep-demo[0].id 
}