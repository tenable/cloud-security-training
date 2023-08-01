resource "aws_ec2_instance_connect_endpoint" "eic-ep-packet-analyzer-demo" {
  subnet_id = aws_subnet.public.id
}

resource "aws_security_group" "eic-ssh-security-group" {
  name = "eic-ssh-to-ec2"
  description = "Security Group to allow the EIC reach the EC2"
  vpc_id = aws_vpc.packet-analyzer-demo.id
  
  tags = {
    Name = "eic-ssh-to-ec2"
  }
}

resource "aws_security_group_rule" "egress_eic_to_ec2" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eic-ssh-security-group.id}"
  source_security_group_id = "${aws_security_group.ec2-ssh-security-group.id}"
}