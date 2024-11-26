locals {
  env_name = terraform.workspace
  # Define CIDR blocks for different environments
  cidr_blocks = {
    dev     = "10.0.1.0/24"
    stage = "10.0.2.0/24"
    prod    = "10.0.3.0/24"
  }

  # Get the CIDR block based on the current environment
  selected_cidr_block = local.cidr_blocks[local.env_name]

  region            = "us-west-2"
  # List of availability zones
  availability_zones = ["us-west-2a", "us-west-2b"]

  secret_name = "${terraform.workspace}/drupal/secrets"
  eks_name          = "drupal-eks"
  eks_version       = "1.29"
  # db_name           = "${local.env_name}rds"
  # db_identifier     = "${local.env_name}-rds-identifier"
  # db_subnet_group_name  = "${local.env_name}-rds-subnet-grp"
   tags = {
    GithubRepo = "terraform-aws-observability-accelerator"
    GithubOrg  = "aws-observability"
  }
}