variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  description = "Application name the virtual machines are provisioned for"
  type        = string
}

variable "ec2_instance_role_name" {
  type        = string
  description = "Role assigned to the EC2 instance(s)"
}
variable "environment_name" {
  type        = string
  description = "Environment name. Possible values: Prod, Staging, Dev"
}

variable "subnet_id" {
  type = string
  description = "VPC Subnet ID"
}
