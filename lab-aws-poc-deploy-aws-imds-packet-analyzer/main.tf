terraform {
  required_version = ">=1.5.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    tls = {
      source  = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
