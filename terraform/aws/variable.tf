variable "aws_region"{
    description = "Where the instance is created"
    type = string
    default = "us-east-1"
}

variable "instance_type"{
    description = "EC2 instance type"
    type = string
    default = "t3-micro"
}

variable "ami"{
    description = "AMI ID"
    type = string
    default = "t3-micro"
}

variable "instance_types_list"{
    description = "EC2 instance type list"
    type = list(string)
    default = ["t2-micro","t3-micro"]
}

variable "instance_types_map"{
    description = "EC2 instance type map"
    type = map(string)
    default = {"dev":"t2-micro","prod":"t3-micro"}
}