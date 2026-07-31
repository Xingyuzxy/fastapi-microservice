# Create IAM Role
locals {
    owners = var.business_divsion
    environment = var.environment
    name = "${var.business_divsion}-${var.environment}"
    common_tags = {
        owners = local.owners
        environment = local.environment     
    }
}


resource "aws_iam_role" "eksClusterRole" {
    name = "eksClusterRole"

    assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eksClusterRole.name
}

# resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#     role       = aws_iam_role.eks_master_role.name
# }

resource "aws_iam_role" "AmazonEKSNodeRole" {
    name = "AmazonEKSNodeRole"

    assume_role_policy = jsonencode({
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        }]
        Version = "2012-10-17"
    })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.AmazonEKSNodeRole.name
}

# resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#     role       = aws_iam_role.eks_nodegroup_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#     role       = aws_iam_role.eks_nodegroup_role.name
# }

# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
    name     = "${local.name}-${var.cluster_name}"
    role_arn = aws_iam_role.eksClusterRole.arn
    version = var.cluster_version

    vpc_config {
        subnet_ids = var.public_subnets
        endpoint_private_access = var.cluster_endpoint_private_access
        endpoint_public_access  = var.cluster_endpoint_public_access
        public_access_cidrs     = var.cluster_endpoint_public_access_cidrs    
    }

    kubernetes_network_config {
        service_ipv4_cidr = var.cluster_service_ipv4_cidr
    }
    
    # Enable EKS Cluster Control Plane Logging
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
    # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
    depends_on = [
        aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
        # aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
    ]
}

# Create AWS EKS Node Group - Public
resource "aws_eks_node_group" "eks_ng_public" {
    cluster_name    = aws_eks_cluster.eks_cluster.name

    node_group_name = "eks-ng-public"
    node_role_arn   = aws_iam_role.AmazonEKSNodeRole.name
    subnet_ids      = var.public_subnets 
    
    ami_type = "AL2_x86_64"  
    capacity_type = "ON_DEMAND"
    disk_size = 20
    instance_types = ["t3.medium"]
    
    
    remote_access {
        ec2_ssh_key = "eks-terraform-key"
    }

    scaling_config {
        desired_size = 1
        min_size     = 1    
        max_size     = 2
    }

    # Desired max percentage of unavailable worker nodes during node group update.
    update_config {
        max_unavailable = 1    
    }

    # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
    # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
    depends_on = [
        aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    #     aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    #     aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    ] 

    tags = {
        Name = "Public-Node-Group"
    }
    }

    # Create AWS EKS Node Group - Private
resource "aws_eks_node_group" "eks_ng_private" {
    cluster_name    = aws_eks_cluster.eks_cluster.name

    node_group_name = "eks-ng-private"
    node_role_arn   = "arn:aws:iam::339713012203:role/AmazonEKSNodeRole"
    subnet_ids      = var.private_subnets
    #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)    
    
    ami_type = "AL2_x86_64"  
    capacity_type = "ON_DEMAND"
    disk_size = 20
    instance_types = ["t3.medium"]
    
    
    remote_access {
        ec2_ssh_key = "eks-terraform-key"    
    }

    scaling_config {
        desired_size = 1
        min_size     = 1    
        max_size     = 2
    }

    # Desired max percentage of unavailable worker nodes during node group update.
    update_config {
        max_unavailable = 1    
        #max_unavailable_percentage = 50    # ANY ONE TO USE
    }

    # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
    # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
    depends_on = [
        aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    #     aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    #     aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    ]  
    tags = {
        Name = "Private-Node-Group"
    }
}


data "aws_partition" "current" {}

# Resource: AWS IAM Open ID Connect Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
    client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
    thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
    url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

    tags = merge(
        {
        Name = "${var.cluster_name}-eks-irsa"
        },
        local.common_tags
    )
}

# Output: AWS IAM Open ID Connect Provider ARN
output "aws_iam_openid_connect_provider_arn" {
    description = "AWS IAM Open ID Connect Provider ARN"
    value = aws_iam_openid_connect_provider.oidc_provider.arn 
}

# Extract OIDC Provider from OIDC Provider ARN
locals {
    aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

# Output: AWS IAM Open ID Connect Provider
output "aws_iam_openid_connect_provider_extract_from_arn" {
    description = "AWS IAM Open ID Connect Provider extract from ARN"
    value = local.aws_iam_oidc_connect_provider_extract_from_arn
}

