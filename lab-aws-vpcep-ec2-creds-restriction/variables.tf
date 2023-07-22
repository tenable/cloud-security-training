# The value of the AWS profile to use 

variable "aws_profile" {
  description = "The AWS profile name to use for provisioning"
  type        = string
  default     = "<INSERT_NAME_OF_PROFILE_HERE>"
} 

# Change the value to true in order to generate the VPC endpoint 

variable "create_s3_vpc_endpoint" {
  description = "Boolean that determines whether to create a VPC endpoint for S3"
  type        = bool 
  default     = false
}

# Change the value to true in order to restrict the usage of the credentials from the EC2 instance 

variable "restrict_ec2_instances_credentials" {
  description = "Boolean that determines whether to apply an IAM policy on the EC2 role to restrict use of its credentials outside of the EC2 making calls via an Endpoint"
  type        = bool 
  default     = false   
}
variable "region" {
  description = "Default region for deployment"
  type = string 
  default = "us-east-1" 
}