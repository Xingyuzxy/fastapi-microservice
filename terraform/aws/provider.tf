# 1. 指定 Terraform 最低版本和所需的 Provider
terraform {
    required_version = ">= 1.0.0"

    required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
    }
    }
}


provider "aws" {
    region = "us-east-1" 
    profile = "default"

    default_tags {
        tags = {
            Environment = "Development"
            ManagedBy   = "Terraform"
        }
    }
}