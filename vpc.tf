# Setting up the VPC, SUbnets, Security Groups, etc.
# Amazon EKS requires subnets must be in at least 2 different AZs
# 1. Create AWS VPC
# 2. Create two public and two private subnets in different AZs
# 3. Create Internet Gateway to provide internet access for service within VPC
# 4. Create NAT Gateway in public subnets. It is used in private subnets to allow services to connect to the internet.
# 5. Create Routing Tables and associate subnets with them. Add required routing rules.
# 6. Create Security Groups and associate subnets with them. Add required routing rules.

# VPC
resource "aws_vpc" "demo" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                           = "${var.project}-vpc",
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.demo.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index] 
  
  tags = {
    Name                                           = "${var.project}-public-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }

  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.demo.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index + var.availability_zones_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]


  tags = {
    Name                                           = "${var.project}-private-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}
