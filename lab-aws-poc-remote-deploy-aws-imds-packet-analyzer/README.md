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

Along with the provisioning of the infrastructure, an SSH key and coressponding key pair are created along with a bash script to perform the installation of aws-imds-packet-analyzer remotely.   
 
## Playbook 

### Initial Deploy 

First, init Terraform: 

    terraform init  

Then, make sure the AWS_PROFILE and AWS_REGION environment variables are properly configured locally. 

Next, we'll deploy the infrastructure. Terraform will need the value of the IP for your local machine (to allow it to SSH to the machine created) in the variable *client_ip*, so the apply command should look like this: 

    terraform apply -var="client_ip=<CLIENT_IP>"

(confirm the deploy with "yes")

As output, you will get two commands - one to perform the installation of the open source library, and the other one to SSH into the instance for further exploration. We recommend that you copy and paste both commands on the side.   

### Installing aws-imds-packet-analyzer 

Run the *install_imds_packet_analyzer_remotely* command to run the bash script created by the Terraform deployment on the EC2 instance and install the open source library and its dependencies on it. It then sets up aws-imds-packet-analyzer to run persistently (using the [forever.js](https://www.npmjs.com/package/forever) library). The script will output logs to your console. 

The command should look something like this: 

    ssh -i packet_analyzer_imds_demo ec2-user@<EC2_INSTANCE_PUBLIC_IP> 'bash -s' < install_imds_packet_analzyer.sh 

**Note:** We strongly recommend that you review the install_imds_packet_analzyer.sh script before execution as it is a good practice to do so with any script you haven't created.  

### Taking The Packet Analyzer Out for a Spin 

You can now SSH into the machine using the SSH command that was output by the Terraform deployment. The command will look something like this: 

    ssh -i packet_analyzer_imds_demo ec2-user@<EC2_INSTANCE_PUBLIC_IP>

If you didn't set aside the SSH command, don't worry, you can regenerate it using:  

    terraform output

Once you're in, you can call this command to create a record in the log for an IMDSv1 call: 

    curl http://169.254.169.254/latest/meta-data/   

Now (while still SSH'd into the machine), you can view the log by cat'ing the local log file: 

    sudo cat /var/log/imds/imds-trace.log 

The output should look something like this: 

![Example Output][example-output-log]

Be sure to note it shows you not only when a call was made and which version of the API it is using but also the exact process which triggered the call along with its parent processes. 

And that's that! 

You've now remotely deployed and tested aws-imds-packet-analyzer. You can imagine how far you can take this approach at scale.

### Clean-up

As always, after completing the demonstration, clean up the environment by running (make sure you exit the SSH connection of course):

    terraform destroy -var="client_ip=<CLIENT_IP>"

Make sure you're OK with the deletion of the resources and confirm with "yes".

## Conclusion 

We hope you find this project useful. We would love to hear what you think. If you have any questions on the topic feel free to reach out to me at liorzat@ermetic.com. 

[packet-analyzer-architecture]: img/packet-analyzer-architecture.png
[example-output-log]: img/example-output-log.png