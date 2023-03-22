# VPC Endpoint and EC2 Credentials Exfiltration Mitigation Lab 

## About 

AWS [recently released](https://aws.amazon.com/blogs/security/how-to-use-policies-to-restrict-where-ec2-instance-credentials-can-be-used-from/) two new condition keys allowing to set very effective guardrails against exfiltration of credentials from EC2 instances, for calls made through VPC endpoints. As we covered in [the Ermetic blog](https://ermetic.com/blog/aws/a-new-incentive-for-using-aws-vpc-endpoints/) this is another major incentive for using VPC endpoints - so we decided we need to make it easier for audiences to use them.  

The terraform project and the playbook below are meant to provide you with hands-on experience provisioning and using a VPC endpoint to better understand how it works. 

In addition, the playbook includes a demonstration of how to use recently released condition keys that allow minimizing the fallout from exfiltration of security credentials from EC2 instances due to misconfigurations - a very common initial access vector for malicious actors. 

During each step of the playbook - make sure you explore the resources created in the AWS console to make the most of the experience. 

## Architecture 

The deployment is a very basic architecture of a VPC with two subnets - one public and one private, each with an EC2 instance deployed to it, along with a VPC endpoint (for demonstration purposes, not provisioned in the initial version of the script - see playbook below) for S3 in us-east-1 (the default region where the script is deployed). 

![Project Architecture][vpc-architecture]

Since the action used in the demonstration is listing existing S3 buckets in an account - it's recommended to run it on an account with existing S3 buckets. 
 
## Playbook 

### Initial Deploy 

After cloning the project - configure the variables.tf file with the value of the AWS profile your CLI is using in the variable *aws_profile*. 

Next - init Terraform: 

    terraform init  

After the initialization of Terraform has completed, you can deploy the initial version of the deployment with:  

    terraform apply 

(confirm the deploy with "yes")

### Accessing S3 

In the initial configuration, it does NOT provision the VPC endpoint in order to demonstrate why it's relevant. You should have the public and private EC2 instances deployed along with the private key of the SSH key pair to connect to the public machine and the output of running the script will give you the commands to do so. 

Run: 

    ssh -i vcpep-demo.pem ec2-user@<PUBLIC_INSTANCE_PUBLIC_IP>

to connect the public machine. 

Once there, you can run: 

    aws s3 ls 

to list the buckets in the account. This should work because the instance profile of the EC2 instance have the permissions to do so, and it's configured to be public so it can access the S3 service. 

After that - you can SSH *from the public machine* to the EC2 instance in the private subnet using the other ssh command the script outputs: 

    ssh -i /tmp/vcpep-demo.pem ec2-user@<PRIVATE_INSTANCE_PRIVATE_IP> 

Once in the machine, you can run: 

    aws s3 ls 

Again - and see that it doesn't work (it should simply hang, you may escape it after a few seconds) - as the machine doesn't have access to the internet and therefor can't access the S3 service. 

### Using a VPC Endpoint 

We will allow the instance in the private subnet to access S3 by creating a VPC endpoint for S3. 

To do so, change the default value of the *create_s3_vpc_endpoint* variable in the variables.tf file to "true" and run: 

    terraform apply 

(you can do this from a differnet cmd terminal window so you don't have to stop your SSH session). 

Now, if you repeat the s3 buckets list command from the private instance - it should work.

### Applying EC2 Credentials Restriction 

Finally, to demonstrate the application of two new condition keys supported by AWS to mitigate the risk of EC2 credentials exfiltration (for more details - read our [blog post on the topic](https://ermetic.com/blog/aws/a-new-incentive-for-using-aws-vpc-endpoints/)) - we demonstrate usage of an IAM policy that leverages them. 

First - let's see what exfiltration of the credentials means. A simple way to simulate this would be to simply run the command: 

    curl http://169.254.169.254/latest/meta-data/iam/security-credentials/s3-list-buckets-access-role 

from the private EC2 instance. You can then take the values making up the credentials the instance uses and configure them as a profile: 

    aws configure --profile EC2_VPC

you should then set the access key and secret, and then run the following command in order to add the session token to the profile: 

    aws configure set aws_session_token <SESSION_TOKEN> --profile EC2_VPC 

You can now run the following command *locally* (just like an attacker could): 

    aws s3 ls --profile EC2_VPC  

In order to deny this, we will apply an inline policy that would enforce making calls using these credentials from the instance. To do so, change the value of the variable *restrict_ec2_instances_credentials* in the variables.tf file and run:

    terraform apply 

Once you do - notice that you can't run the S3 command locally using the harvested credntials. You can still run the command from the private EC2 instance! 

One final point to notice - if you now try to run the command from the *public* instance (which uses the same instance profile and thus the restriction would apply to it as well) - it won't work, as the values for the new condition keys only exist in events generated by calls made through a VPC endpoint - and that's yet another lesson of why it's important to use such a restriction with extreme care so you don't break anything. 

As always - after being done with the demonstration - clean up the environment by running:

    terraform destroy  

(confirm with yes)

## Conclusion 

Hope you find this project useful - if you have any questions about this topic, feel free to reach out to me at liorzat@ermetic.com. 

## Important Notes

* Note the [AWS PrivateLink pricing](https://aws.amazon.com/privatelink/pricing/). 
* In the target account where you run the demonstration, there may be guardrails in place such as a Service Control Policy (SCP) applied that may limit the functionality of this workshop. If you run into unexpected "Access Denied" events - I recommend the [Access Undenied tool](https://github.com/ermetic/access-undenied-aws) for debugging. 

[vpc-architecture]: img/vpc_architecture.png