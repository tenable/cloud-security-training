output "ssh_to_machine_command" {
    value = "aws ec2-instance-connect ssh --instance-id ${aws_instance.ec2-instance-packet-analyzer-demo.id} --connection-type eice --os-user ec2-user"
}