include "root" {
    path = find_in_parent_folders("root.hcl")
}


# ---------- 定义模块来源 ----------
terraform {
    source = "${get_parent_terragrunt_dir()}/modules/aws/vpc"
}

# ---------- 输入参数 ----------
inputs = {
    aws_region = "us-east-1"
}