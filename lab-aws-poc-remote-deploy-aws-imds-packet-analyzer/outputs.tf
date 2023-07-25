output "ssh_to_machine_command" {
    value = "ssh -i packet_analyzer_imds_demo ec2-user@${aws_instance.ubuntu-ec2-packet-analyzer-demo.public_ip}"
}

output "install_imds_packet_analyzer_remotely" {
    value = "ssh -i packet_analyzer_imds_demo ec2-user@${aws_instance.ubuntu-ec2-packet-analyzer-demo.public_ip} 'bash -s' < install_imds_packet_analzyer.sh"
}

resource "local_file" "packet_analyzer_installation_script" {
    content = <<EOF
sudo amazon-linux-extras enable BCC
sudo yum -y install kernel-devel-$(uname -r)
sudo yum -y install bcc 

wget https://github.com/aws/aws-imds-packet-analyzer/archive/refs/heads/main.zip 
unzip main.zip 

sudo yum update -y 
curl –sL https://rpm.nodesource.com/setup_14.x | sudo bash - 
sudo yum install nodejs -y  

sudo npm install -g forever  
sudo forever start -c python3 /home/ec2-user/aws-imds-packet-analyzer-main/src/imds_snoop.py

EOF 
    filename = "install_imds_packet_analzyer.sh"
}