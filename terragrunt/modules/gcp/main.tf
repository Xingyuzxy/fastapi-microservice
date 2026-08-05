module "vpc" {
    source = "./vpc"
}

module "gks" {
    source = "./gks"
    vpc_self_link = module.vpc.vpc_self_link
    subnet_self_link = module.vpc.subnet_self_link
}