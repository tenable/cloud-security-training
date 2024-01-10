data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"] 
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-ebs"]
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
} 

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "vpcep-demo.pem"
  file_permission = "0600"
}   

resource "aws_key_pair" "vpcep-demo" {
  key_name   = "vpcep-demo-keypair"
  public_key = tls_private_key.ssh.public_key_openssh 

  tags = {
    Name = "vpcep-demo-keypair"
  }
} 

resource "aws_instance" "public" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name      = "vpcep-demo-keypair"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]
  
  iam_instance_profile = aws_iam_instance_profile.instance_profile_list_all_buckets.name
  
  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name      = "vpcep-demo-keypair"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  
  iam_instance_profile = aws_iam_instance_profile.instance_profile_list_all_buckets.name 

  metadata_options {
      http_endpoint = "enabled"
      http_tokens = "optional"
  } 

  tags = {
    Name = "private-instance"
  }
}

resource "null_resource" "ssh_config" {
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.ssh.private_key_pem
    host     = aws_instance.public.public_ip
  }

  provisioner "file" {
    source = "vpcep-demo.pem"
    destination = "/tmp/vpcep-demo.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /tmp/vpcep-demo.pem"
    ]
  }
}