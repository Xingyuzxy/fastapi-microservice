resource "aws_vpc" "vpc_network_eks" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
    vpc_id                  = aws_vpc.vpc_network_eks.id
    cidr_block              = "10.0.0.0/28" 
}

resource "aws_instance" "instance1" {

    ami           = "ami-0fe3999acbfd542d0"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.my_subnet.id
}