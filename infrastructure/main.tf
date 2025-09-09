# module "networking" {
#   source = "modules/networking"
# }
#
# module "vpc" {
#   source = "modules/vpc"
# }
#
# module "servers" {
#   source = "modules/servers"
# }

################# NETWORK ######################################
# TODO: use different VPC and subnets for different environments
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc-${var.environment_name}"
  }
}


resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.vpc_subnet_cidr_block
  # availability_zone       = "us-east-1a"   # Optional: choose a specific AZ
  # map_public_ip_on_launch = true           # Optional: if launching public instances

  tags = {
    Name = "main-subnet-${var.environment_name}"
  }
}

################# EC2 ######################################
data "aws_ec2_instance_type" "ec2_instance" {
  instance_type = "t3.micro"
}

data "aws_ami" "amazon_linux" {
  # Supporting different regions

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2_instance_001" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = data.aws_ec2_instance_type.ec2_instance.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id = aws_subnet.subnet1.id

  tags = {
    Name = "ec2-sqs-${var.environment_name}"
    Environment = var.environment_name
    AppName = var.app_name
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "Ec2InstanceProfile"
  role = aws_iam_role.sqs_read_write_role.name
}


# TODO: move to it's module
data "aws_caller_identity" "current" {}

################# SQS ######################################

resource "aws_sqs_queue" "simple_sqs_001" {
  name = "standard-sqs-001-${var.environment_name}"
  max_message_size = 1024 # 1024 byte. Default (256 KiB)
  message_retention_seconds = 86400
  # Long polling.  Time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning
  receive_wait_time_seconds = 5
  visibility_timeout_seconds = 30 # Default 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount = 5
  })

  tags = {
    Environment = var.environment_name
    AppName = var.app_name
  }
}

resource "aws_sqs_queue" "dlq" {
  name = "dlq-001"

  tags = {
    Environment = var.environment_name
    AppName = var.app_name
  }
}

##############SQS Security######################

resource "aws_iam_role" "sqs_read_write_role" {
  name = "SqsReadWriteRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# TODO: SQS Access policy list is empty
resource "aws_iam_policy" "sqs_read_write_policy" {
  name        = "SQSReadWritePolicy"
  description = "Allow EC2 read/write access to a specific SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.simple_sqs_001.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sqs_policy_to_role" {
  role       = aws_iam_role.sqs_read_write_role.name
  policy_arn = aws_iam_policy.sqs_read_write_policy.arn
}


