variable "admin_users" {
  description = "List of IAM user names allowed to assume the infrastructure admin role"
  type        = list(string)
}

variable "access_key" {
  description = "AWS IAM user access key"
  type        = string
}

variable "secret_key" {
  description = "AWS IAM user secret key"
  type        = string
}