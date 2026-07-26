resource "aws_vpc" "vpc_network_eks" {
    cidr_block = "10.0.0.0/16"
}