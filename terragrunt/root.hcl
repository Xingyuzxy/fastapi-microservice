locals {
  cloud = get_env("CLOUD_PROVIDER", "aws")
  environment = get_env("ENVIRONMENT", "dev")
  
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    Project     = "MultiCloudInfra"
  }
}

remote_state {
  backend = "s3" 
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
