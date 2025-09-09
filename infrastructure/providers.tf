provider "aws" {
  region = var.aws_region


  default_tags {
    tags = {
      Environment     = "Test"
      Service         = "Example"
      HashiCorp-Learn = "aws-default-tags"
    }
  }
}