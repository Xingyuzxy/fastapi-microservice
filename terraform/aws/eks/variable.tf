variable "aws_region" {
    description = "Region in which AWS Resources to be created"
    type = string
    default = "us-east-1"  
}
# Environment Variable
variable "environment" {
    description = "Environment Variable used as a prefix"
    type = string
    default = "dev"
}
# Business Division
variable "business_divsion" {
    description = "Business Division in the large organization this Infrastructure belongs"
    type = string
    default = "HR"
}

# EKS Cluster Input Variables
variable "cluster_name" {
    description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
    type        = string
    default     = "eksdemo"
}

variable "cluster_service_ipv4_cidr" {
    description = "service ipv4 cidr for the kubernetes cluster"
    type        = string
    default     = null
}

variable "cluster_version" {
    description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
    type = string
    default     = "1.31"
}
variable "cluster_endpoint_private_access" {
    description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
    type        = bool
    default     = false
}

variable "cluster_endpoint_public_access" {
    description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
    type        = bool
    default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
    description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

variable "eks_oidc_root_ca_thumbprint" {
    type        = string
    description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
    default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "public_subnets" {
    type = list(string)
    default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_id" {
    type = string
    default = "123"
}

data "aws_ami" "amzlinux2" {
    most_recent = true
    owners = [ "amazon" ]
    filter {
        name = "name"
        values = [ "amzn2-ami-hvm-*-gp2" ]
    }
    filter {
        name = "root-device-type"
        values = [ "ebs" ]
    }
    filter {
        name = "virtualization-type"
        values = [ "hvm" ]
    }
    filter {
        name = "architecture"
        values = [ "x86_64" ]
    }
}


data "aws_ssm_parameter" "node_ami" {
    name = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2/recommended/image_id"
}
















variable "use_predefined_role" {
    type        = bool
    description = "Whether to use predefined cluster service role, or create one."
    default     = false
}

# KK Playground. Node role must be called 'eksWorkerNodeRole'
variable "node_role_name" {
    type        = string
    description = "Name of node role"
    default     = "eksWorkerNodeRole"
}

# KK Playground. Policy role must be called 'eksPolicy'
variable "additional_policy_name" {
    type = string
    description = "Name of IAM::Policy created for additional permissions"
    default = "eksPolicy"
}

variable "node_group_desired_capacity" {
    type        = number
    description = "Desired capacity of Node Group ASG."
    default     = 3
}
variable "node_group_max_size" {
    type        = number
    description = "Maximum size of Node Group ASG. Set to at least 1 greater than node_group_desired_capacity."
    default     = 4
}

variable "node_group_min_size" {
    type        = number
    description = "Minimum size of Node Group ASG."
    default     = 1
}