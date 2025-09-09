provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment     = var.environment_name
      Service         = var.app_name
      HashiCorp-Learn = "aws-default-tags"
    }
  }
}