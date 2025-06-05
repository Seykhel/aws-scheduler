terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "aws-scheduler-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-scheduler-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}
