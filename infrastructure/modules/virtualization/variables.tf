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

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "subnet_id" {
  type = string
  description = "VPC Subnet ID"
}

#### ECS ####

variable "aws_account_id" {

}

variable "docker_image_name" {
  description = "Docker image name with tag. Example: image-name:tag"
  default = "events-api:latest"
}

variable "docker_container_port" {
  description = "Application port inside the docker container"
  type = number
  default = 8080
}

variable "task_cpu" {
  description = "CPU units for Fargate task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for Fargate task (MB)"
  type        = string
  default     = "512"
}