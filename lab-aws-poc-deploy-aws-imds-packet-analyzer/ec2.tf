# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"] 
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-ebs"]
  }
}

#Security Groups
resource "aws_security_group" "ec2-ssh-security-group" {
  name = "ec2-ssh-public-access"
  description = "Security Group for EC2 Instance over SSH"
  vpc_id = aws_vpc.packet-analyzer-demo.id

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
  tags = {
    Name = "ec2-ssh-public-access"
  }
}

resource "aws_security_group_rule" "ingress_eic_to_ec2" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.ec2-ssh-security-group.id}"
  source_security_group_id = "${aws_security_group.eic-ssh-security-group.id}"
}

resource "aws_security_group_rule" "ingress_client_to_ec2" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.ec2-ssh-security-group.id}"
  cidr_blocks       =  ["${var.client_public_ip}/32"]
}

#EC2 Instance
resource "aws_instance" "ec2-instance-packet-analyzer-demo" {
    ami = data.aws_ami.amazon-linux-2.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
     
    vpc_security_group_ids = [
        "${aws_security_group.ec2-ssh-security-group.id}"
    ]
    
    metadata_options {
      http_endpoint = "enabled"
      http_tokens = "optional"
    }

    root_block_device {
        volume_type = "gp3"
        volume_size = 8
        delete_on_termination = true
    }

    tags = {
        Name = "ec2-instance-packet-analyzer-demo"
    }
}
