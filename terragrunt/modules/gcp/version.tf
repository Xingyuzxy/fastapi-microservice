# Terraform Settings Block
terraform {
    required_version = ">= 1.0.0"
    required_providers {
        google = {
        source = "hashicorp/google"
        version = ">= 5.34.0"
        }
    }
}
