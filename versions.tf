terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"  # Versione minima che supporta le risorse S3 separate
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
  
  # Ignora i tag per evitare warning durante l'import
  default_tags {
    tags = {}
  }
}
