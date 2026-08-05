module "vpc" {
    source = "./vpc"
}

module "aks" {
    source = "./aks"
}