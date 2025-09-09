variable "aws_region" {
  default = "us-east-1"
}

variable "environment_name" {
  type        = string
  description = "Environment name. Possible values: Prod, Staging, Dev"
}
