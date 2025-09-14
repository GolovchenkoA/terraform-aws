###############################Private Networks#############################
# TODO: They are not used now. Everything is deployed in the default public networks


locals {
  # us-east-1a is used because ec2 t3.micro is not available in us-east-1e, for example
  az = "us-east-1a"
}

# TODO: since it's a new vpc it's isolated from other networks
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc-${var.environment_name}"
  }
}

# TODO: use different VPC and subnets for different environments
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.vpc_subnet_cidr_block
  availability_zone       = local.az   # Optional.
  # map_public_ip_on_launch = true           # Optional: if launching public instances

  tags = {
    Name = "${local.az}-subnet-private-${var.environment_name}"
  }
}