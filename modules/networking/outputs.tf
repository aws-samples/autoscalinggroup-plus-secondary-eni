output "public_subnets" {
    value = aws_subnet.public_subnets.*
}

output "private_subnets" {
    value = aws_subnet.private_subnets.*
}



output "vpc_id" {
    value = aws_vpc.main.id
}

output "igw" {
    value = aws_internet_gateway.igw.id
}

output "sg_default" {
    value = aws_security_group.sg_default.id
} 

output "management_sg" {
    value = aws_security_group.management_sg.id
}
