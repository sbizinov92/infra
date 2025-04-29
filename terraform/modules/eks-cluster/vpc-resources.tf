# Create VPC resources for EKS cluster

locals {
  # Force VPC creation since we know no VPC exists
  create_vpc = true
  
  # CIDR blocks for new VPC and subnets - only using 2 AZs (a and b)
  vpc_cidr        = var.vpc_cidr
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
}

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-vpc"
    }
  )
}

# Create Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-igw"
    }
  )
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(local.private_subnets)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-private-${local.azs[count.index]}"
      "kubernetes.io/role/internal-elb" = "1"
      tier = "private"
      environment = "infra"
    }
  )
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(local.public_subnets)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-public-${local.azs[count.index]}"
      "kubernetes.io/role/elb" = "1"
      tier = "public"
      environment = "infra"
    }
  )
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = 1  # Single NAT Gateway for all AZs
  
  domain = "vpc"
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-nat-eip-${local.azs[0]}"
    }
  )
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  count = 1  # Single NAT Gateway for all AZs
  
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-nat-gw-${local.azs[0]}"
    }
  )
  
  depends_on = [aws_internet_gateway.igw]
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-public-rt"
    }
  )
}

# Add route to Internet Gateway for public route table
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create route tables for private subnets
resource "aws_route_table" "private" {
  count = length(local.private_subnets)
  
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-private-rt-${local.azs[count.index]}"
    }
  )
}

# Add route to NAT Gateway for private route tables
resource "aws_route" "private_nat_gateway" {
  count = length(local.private_subnets)
  
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id  # All routing through single NAT Gateway
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(local.public_subnets)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count = length(local.private_subnets)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}