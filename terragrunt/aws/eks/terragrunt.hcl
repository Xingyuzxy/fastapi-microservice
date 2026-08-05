# aws/dev/networking/vpc/terragrunt.hcl
# 功能：在 AWS Dev 环境创建 VPC 及网络资源

# ---------- 继承父级配置 ----------
include "root" {
    path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
    config_path = "../vpc"

    # 如果 VPC 还没 apply 过，为了防止 terragrunt 报错，可以给个默认模拟输出
    mock_outputs = {
        vpc_id             = "vpc-mock-id"
        private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
        cluster_service_ipv4_cidr = "192.168.0.1/24"
    }
    mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# ---------- 定义模块来源 ----------
terraform {
    source = "${get_parent_terragrunt_dir()}/modules/aws/eks"
}

# ---------- 输入参数 ----------
inputs = {
    aws_region = "us-east-1"
    environment = "dev"
    business_divsion = "HR"
    cluster = "eksdemo"
    cluster_version = "1.31"
    cluster_service_ipv4_cidr = dependency.vpc.cluster_service_ipv4_cidr

    cluster_endpoint_private_access=false
    cluster_endpoint_public_access=true
    cluster_endpoint_public_access_cidrs=["0.0.0.0/0"]
    eks_oidc_root_ca_thumbprint="9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    public_subnets=
    private_subnets=
    vpc_id=dependency.vpc.vpc_id

    use_predefined_role=false
    node_role_name="eksWorkerNodeRole"
    additional_policy_name="eksPolicy"
    node_group_desired_capacity = 3 
    node_group_max_size = 4
    node_group_min_size 1 
}


