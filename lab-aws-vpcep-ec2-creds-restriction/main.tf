terraform {
  required_version = ">=0.12.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    tls = {
      source  = "hashicorp/tls"
    }
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  profile = var.aws_profile
  region  = var.region
}

provider "tls" {} 