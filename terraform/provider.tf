terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33"
    }
  }

  backend "s3" {
    bucket         = "collabinfra-devopsdays"
    key            = "terraform/dev"
    region         = "ca-central-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:ca-central-1:539163648468:key/6a20c511-dd35-43d5-94d1-c5c6c8ba1682"
    dynamodb_table = "devops-days"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      Environment = "prod"
      Service     = "jira"
      Version     = "9.2.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
