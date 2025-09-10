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
  source = "./modules/virtualization"
  aws_region = var.aws_region
  environment_name = var.environment_name
  subnet_id = module.network.subnet_id
  app_name = var.app_name
  ec2_instance_role_name = module.sqs.ec2_sqs_role_name
}

