# Lab: Remote Deploy POC of aws-imds-packet-analyzer  

## TL;DR 

This lab is a proof-of-concept lab that allows you to easily deploy and test the [aws-imds-packet-analyzer](https://github.com/aws/aws-imds-packet-analyzer) tool that AWS recently released. 

## About 

AWS recently released an open source library called [aws-imds-packet-analyzer](https://github.com/aws/aws-imds-packet-analyzer) which, as the name suggests, can be used as a tool to analyze packets sent to the IMDS (instance metadata service) of EC2 instances. 

The library is intended to be installed locally on EC2 instances. Its function is to log the requests made to the IMDS with information such as the IMDS version (v1/v2) for which the request was made and from which process.

The library is another excellent example of AWS supporting its customers in enforcing IMDSv2. To understand why enforcing IMDSv2 is important, we invite you to read a [post we published on the matter](https://ermetic.com/blog/aws/aws-ec2-imds-what-you-need-to-know/).  

### Important Notes 
- This lab is meant for experimentation and learning purposes ONLY! We do not recommend using it in production envrionments and certainly not without proper testing.
- The project architecture was designed to quickly demonstrate the deployment of the aws-imds-packet-analyzer library and show how it is *possible* to do the deployment remotely. It is not necessarily a recommended architecture for any kind of instance - for example, the instance deployed is public to the internet (to make it easy to download aws-imds-packet-analyzer and its dependencies); for other purposes, the architecture can and should be designed differently.
- Before using the lab, make sure you are aware of and prepared to cover any costs its use may entail. 

## Why aws-imds-packet-analyzer Matters 

Before enforcing IMDSv2 (basically, disabling IMDSv1) you need to make sure that no legitimate workloads running on the instance are using IMDSv1 and need it to function.  

AWS offers several tools for detecting calls to IMDSv1. This library enables you not only to know which calls were made but also which process made them, as well as which process triggered the process that made the call, which process triggered the process that triggered it, etc. Such information is invaluable for executing a procedure that replaces the code making the request with a version updated to use IMDSv2, enabling you to retire IMDSv1. 

## Project Architecture 

![Project Architecture][packet-analyzer-architecture]

## How This Lab Works 

The lab deploys a VPC, a public subnet along with an Internet Gateway, and an EC2 instance with an Amazon Linux 2 AMI, a public IP and IMDSv1 enabled.  

Along with the provisioning of the infrastructure, an SSH key and corresponding key pair are created along with a bash script to perform the installation of aws-imds-packet-analyzer remotely. 
 
## Playbook 

### Initial Deploy 

First, init Terraform: 

    terraform init  

Then, make sure the AWS_PROFILE and AWS_REGION environment variables are properly configured locally. 

Next, we'll deploy the infrastructure. Terraform will need the value of the **public** IP for your local machine (to allow it to SSH to the machine created) in the variable *client_public_ip*, so the apply command should look like this: 

    terraform apply -var="client_public_ip=<CLIENT_PUBLIC_IP>"

(confirm the deploy with "yes")

As output, you will get the command to SSH into the machine created using the [EC2 instance connect service](https://aws.amazon.com/blogs/compute/secure-connectivity-from-public-to-private-introducing-ec2-instance-connect-endpoint-june-13-2023/).   

### Installing aws-imds-packet-analyzer 

Connect to the machine using the command received in the previous step and run the [install_imds_packet_analzyer.sh](script/install_imds_packet_analzyer.sh) script within it. Find the script in the [script](script/) folder of this repository. 

The easiest way to run the script is to simply copy and paste its contents to the terminal. 

The script will install and set up aws-imds-packet-analyzer to run as a Linux service.

**Note:** We strongly recommend that you review the install_imds_packet_analzyer.sh script before execution as doing so is good practice with any script you haven't created.  

### Taking the Packet Analyzer Out for a Spin 

Once the installation is done, you should be able to view the status of the newly created service with the following command: 

    sudo systemctl status imds_packet_analyzer_service 

Once you've made sure it's up and running, let's try it out. 

You can use this command to create a record in the log for an IMDSv1 call: 

    curl http://169.254.169.254/latest/meta-data/   

Now (while still SSH'd into the machine) you can view the log by cat'ing the local log file:  

    sudo cat /var/log/imds/imds-trace.log 

The output should look something like this: 

![Example Output][example-output-log]

Be sure to note it shows you not only when a call was made and which version of the API it is using but also the exact process which triggered the call along with its parent processes. 

And that's that! 

You've now remotely deployed and tested aws-imds-packet-analyzer. You can imagine how far you can take this approach at scale.

### Clean-up

As always, after completing the demonstration, clean up the environment by running (make sure you exit the SSH connection of course):

    terraform destroy -var="client_public_ip=<CLIENT_PUBLIC_IP>"

Make sure you're OK with the deletion of the resources and confirm with "yes".

## Conclusion 

We hope you find this project useful. We would love to hear what you think. If you have any questions on the topic feel free to reach out to me at liorzat@ermetic.com. 

[packet-analyzer-architecture]: img/packet-analyzer-architecture.png
[example-output-log]: img/example-output-log.png