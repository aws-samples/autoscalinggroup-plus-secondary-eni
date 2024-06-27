data "aws_availability_zones" "available" {}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

# Gateway (Internet and NAT)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_eip" "nat_eip" {

  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Public/Private Subnet creation 

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public-subnet-${count.index + 1}"
  }

}

resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "management_subnets" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.management_subnets_cidr)
  cidr_block        = element(var.management_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name    = "${var.project}-management-subnet-${count.index + 1}"
    Purpose = "management"
  }
}



# Route table, routes, associations

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-private-rt"
  }
}



resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_nat" {

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}



resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id

}
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "management" {
  count          = length(var.management_subnets_cidr)
  subnet_id      = aws_subnet.management_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security groups

resource "aws_security_group" "sg_default" {
  name   = "${var.project}-default-sg"
  vpc_id = aws_vpc.main.id
  depends_on = [
    aws_vpc.main
  ]
  ingress {
    description = "TCP traffic from nlb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "management_sg" {
  name   = "${var.project}-management-sg"
  vpc_id = aws_vpc.main.id
  depends_on = [
    aws_vpc.main
  ]
  ingress {
    description = "SSH for management group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Purpose = "management"
  }

}
