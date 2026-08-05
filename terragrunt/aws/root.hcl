# infrastructure-live/aws/root.hcl
include "root" {
    path = find_in_parent_folders("root.hcl")
}

locals {
    aws_account_ids = {
        dev  = "123456789012"
        prod = "987654321098"
    }
    
    aws_account_id = local.aws_account_ids[local.environment]
    region = get_env("AWS_REGION", "us-east-1")
    

    aws_tags = merge(local.common_tags, {
        CloudProvider = "AWS"
    })
}

# 生成 AWS Provider
generate "provider" {
    path      = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents  = <<EOF
    provider "aws" {
    region = "${local.region}"
    
    default_tags {
        tags = ${jsonencode(local.aws_tags)}
    }
}
EOF
}


remote_state {
    backend = "s3"
    config = {
        bucket         = "mybucket-terraform-state-${local.aws_account_id}"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = local.region
        encrypt        = true
        dynamodb_table = "terraform-locks-${local.environment}"
    }
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
}

inputs = {
    aws_account_id = local.aws_account_id
    aws_region     = local.region
    aws_tags       = local.aws_tags
}