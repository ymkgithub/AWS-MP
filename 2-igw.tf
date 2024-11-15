resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.env_vpc.id

  tags = {
    Name = "${local.env_name}-igw"
  }
}
