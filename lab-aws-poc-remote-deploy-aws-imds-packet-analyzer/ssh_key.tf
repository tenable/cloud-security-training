resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
} 

resource "local_file" "private_key" {
  filename        = "packet_analyzer_imds_demo" 
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0400"
}

resource "local_file" "public_key" {
  filename = "packet_analyzer_imds_demo.pub"
  content  = tls_private_key.ssh.public_key_openssh
}

resource "aws_key_pair" "key_pair" {
  key_name   = "packet-analyzer-demo-keypair"
  public_key = tls_private_key.ssh.public_key_openssh 

  tags = {
    Name = "packet-analyzer-demo-keypair"
  }
}  