variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  description = "Application name the virtual machines are provisioned for"
  type        = string
}

variable "sqs_read_write_access_role_name" {
  type        = string
  description = "Role with access to sqs"
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
  type = number
  default = 256  # virtual cpu. 1024 = 1 vCPU, 512 = 0,5 vCPU
}

variable "task_memory" {
  description = "Memory for Fargate task (MB)"
  type = number
  default = 512
}

### SQS ###

variable "sqs_main_url" {
  description = "SQS URL that's used by the app"
  type = string
}