#!bin/bash 

sudo yum -y update 
sudo yum -y install wget.x86_64
sudo yum -y install unzip  

sudo amazon-linux-extras enable BCC
sudo yum -y install bcc 
sudo yum -y clean metadata 
sudo yum -y install bcc 

sudo yum -y install kernel-devel-$(uname -r)

rm -r main.zip 
wget https://github.com/aws/aws-imds-packet-analyzer/archive/refs/heads/main.zip 
sudo unzip main.zip

# Path to the Python script
python_script="/home/ec2-user/aws-imds-packet-analyzer-main/src/imds_snoop.py"

# Name of the service
service_name="imds_packet_analyzer_service"

# Path for the .service file
service_file="/etc/systemd/system/${service_name}.service"

# Create the .service file using a here document
cat << EOF | sudo tee "$service_file"
[Unit]
Description=IMDS Packet Analyzer Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $python_script
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start "$service_name"
sudo systemctl enable "$service_name"