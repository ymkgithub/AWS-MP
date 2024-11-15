# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = cidrsubnet(local.selected_cidr_block, 2, 0) # First public subnet
  availability_zone = local.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    "Name"                                                 = "${local.env_name}-public-${local.availability_zones[0]}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env_name}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = cidrsubnet(local.selected_cidr_block, 2, 1) # Second public subnet
  availability_zone = local.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    "Name"                                                 = "${local.env_name}-public-${local.availability_zones[1]}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env_name}-${local.eks_name}" = "owned"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = cidrsubnet(local.selected_cidr_block, 2, 2) # First private subnet
  availability_zone = local.availability_zones[0]
  tags = {
    "Name"                                                 = "${local.env_name}-private1-${local.availability_zones[0]}"
    "kubernetes.io/role/internal-elb"                      = "1"
    "kubernetes.io/cluster/${local.env_name}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = cidrsubnet(local.selected_cidr_block, 2, 3) # Second private subnet
  availability_zone = local.availability_zones[1]
  tags = {
    "Name"                                                 = "${local.env_name}-private2-${local.availability_zones[1]}"
    "kubernetes.io/role/internal-elb"                      = "1"
    "kubernetes.io/cluster/${local.env_name}-${local.eks_name}" = "owned"
  }
}