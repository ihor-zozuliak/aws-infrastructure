# CREATE VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc-name
  }
}

# CREATE SUBNETS
# list of available availability zone names
data "aws_availability_zones" "available" {
  state = "available"
}
# subnets for availability zone us-west-2a
resource "aws_subnet" "subnet-public-a" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = cidrsubnet(var.vpc-cidr, 8, 1)
  availability_zone               = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = true
  tags = {
    Name = var.subnet-a-name[0]
  }
}
resource "aws_subnet" "subnet-private-a" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = cidrsubnet(var.vpc-cidr, 8, 2)
  availability_zone               = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false
  tags = {
    Name = var.subnet-a-name[1]
  }
}
resource "aws_subnet" "subnet-db-a" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = cidrsubnet(var.vpc-cidr, 8, 3)
  availability_zone               = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false
  tags = {
    Name = var.subnet-a-name[2]
  }
}

# ELASTIC IP ALLOCATION
# elastic IP allocation for NAT gateway
resource "aws_eip" "eip-nat" {
  tags = {
    Name = var.eip-name[0]
  }
}

# CREATE GATEWAYS
# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw-name
  }
}
# NAT gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.subnet-public-a.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = var.nat-name
  }
}

# CREATE ROUTING
# allows Terraform manage VPC's main route table
resource "aws_default_route_table" "routetb-main" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = var.routetb-name[0]
  }
}
# create route tables for public and private subnets
resource "aws_route_table" "routetb-public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.routetb-name[1]
  }
}
resource "aws_route_table" "routetb-private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.routetb-name[2]
  }
}
# create routing rules for public and private route tables
resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.routetb-public.id
  destination_cidr_block = var.all-ip
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.routetb-private.id
  destination_cidr_block = var.all-ip
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
}
# associate route tables with subnets in AZ-A
resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = aws_subnet.subnet-public-a.id
  route_table_id = aws_route_table.routetb-public.id
}
resource "aws_route_table_association" "private-subnet-association" {
  subnet_id      = aws_subnet.subnet-private-a.id
  route_table_id = aws_route_table.routetb-private.id
}
