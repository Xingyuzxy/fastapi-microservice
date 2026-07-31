provider "aws" {
    region = var.aws_region 
    profile = "default"

    default_tags {
        tags = {
            Environment = "Development"
            ManagedBy   = "Terraform"
        }
    }
}

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_name   
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_name 
}

# 3. 后续的 Kubernetes / Helm 配置（例如配置 provider）
provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
}