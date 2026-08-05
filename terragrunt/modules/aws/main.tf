module "vpc" {
    source = "./vpc"
}

module "eks" {
    source = "./eks"
    public_subnets = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id
}