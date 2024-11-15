resource "aws_vpc" "env_vpc" {
  cidr_block = local.selected_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${local.env_name}-vpc"
    Environment = local.env_name
  }
}
