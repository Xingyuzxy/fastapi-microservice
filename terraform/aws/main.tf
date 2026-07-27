resource "aws_vpc" "vpc_network_eks" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
    vpc_id                  = aws_vpc.vpc_network_eks.id
    cidr_block              = "10.0.0.0/28" 
}

resource "aws_security_group" "allow_tls" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic and all outbound traffic"
    vpc_id      = aws_vpc.vpc_network_eks.id

    ingress {
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = [aws_vpc.vpc_network_eks.id]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

}

resource "aws_instance" "instance1" {

    ami           = "ami-0fe3999acbfd542d0"
    instance_type = var.instance_type
    count = 2
    subnet_id = aws_subnet.my_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
}