variable "aws_region" {
  default = "us-east-1"
}

variable "environment_name" {
  type        = string
  description = "Environment name. Possible values: Prod, Staging, Dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC. Example 10.0.0.0/16"
}
variable "vpc_subnet_cidr_block" {
  description = "CIDR block for VPC subnet. Example 10.0.1.0/26"
}
