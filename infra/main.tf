terraform {
  required_version = ">= 1.10.0"
  cloud {
    organization = "docmost-devops"

    workspaces {
      project = "Docmost"
      name    = "docmost-prod"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}