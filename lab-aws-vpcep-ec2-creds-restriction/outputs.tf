output "private_instance_private_ip_addr" {
  value = "ssh -i /tmp/vpcep-demo.pem ec2-user@${aws_instance.private.private_ip}"
}

output "public_instance_public_ip_addr" {
  value = "ssh -i vpcep-demo.pem ec2-user@${aws_instance.public.public_ip}"
}

