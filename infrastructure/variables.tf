variable "app_name" {
  description = "Application name the infrastructure is provisioned for"
  type        = string
  default = "app-001"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC. Example 10.0.0.0/16"
}
variable "vpc_subnet_cidr_block" {
  description = "CIDR block for VPC subnet. Example 10.0.1.0/26"
}

variable "environment_name" {
  description = "Environment name. Possible values: Prod, Staging, Dev"
  type        = string
}

# TODO: implement or remove
variable "sqs_users" {
  description = "User that should have access to SQS"
  type        = list(string)
  default = []
}
