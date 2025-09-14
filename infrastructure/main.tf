data "aws_caller_identity" "current" {}

######################## Public Networks ##################################
data "aws_vpc" "default_vpc_us-east-01" {
  id = "vpc-0405fb387d6c49dde"
}

# Get the default subnet in us-east-1a
data "aws_subnets" "default_subnets_in_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc_us-east-01.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnet" "default_subnet" {
  id = data.aws_subnets.default_subnets_in_vpc.ids[0]
}
#######################################################################


module "network" {
  source = "./modules/networking"
  aws_region = var.aws_region
  environment_name = var.environment_name
  vpc_cidr_block = var.vpc_cidr_block
  vpc_subnet_cidr_block = var.vpc_subnet_cidr_block
}

module "sqs" {
  source = "./modules/sqs"
  environment_name = var.environment_name
  app_name = var.app_name
}

module "virtualization" {
  aws_account_id = data.aws_caller_identity.current.account_id
  source = "./modules/virtualization"
  aws_region = var.aws_region
  environment_name = var.environment_name
  vpc_id = data.aws_vpc.default_vpc_us-east-01.id
  subnet_id = data.aws_subnet.default_subnet.id
  app_name = var.app_name
  sqs_read_write_access_role_name = module.sqs.sqs_read_write_access_role_name
  sqs_main_url = module.sqs.sqs_main_url
}

