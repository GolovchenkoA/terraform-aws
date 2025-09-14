################# EC2 ######################################
data "aws_ec2_instance_type" "ec2_instance" {
  instance_type = "t3.micro"
}

data "aws_ami" "amazon_linux" {
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
  subnet_id =  var.subnet_id

  tags = {
    Name = "ec2-sqs-${var.environment_name}"
    Environment = var.environment_name
    AppName = var.app_name
  }
}

data "aws_iam_role" "sqs_read_write_role" {
  # TODO: check. how this role is related to "SQSReadWritePolicy" below
  name = var.sqs_read_write_access_role_name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "Ec2InstanceProfile"
  role =  data.aws_iam_role.sqs_read_write_role.name
}

####################### ECS #######################

data "aws_iam_policy" "sqs_read_write_policy" {
  name = "SQSReadWritePolicy"
}

locals {
  ecs_cloud_watch_log_group_name = "/ecs/${var.app_name}"
}

# ECS Service (runs container permanently)
resource "aws_ecs_service" "service" {
  name            = "ecs-service-${var.environment_name}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # For some reason it requires additional settings because terraform says the config is invalid
  # enable_execute_command = true # enable ECS Exec for tasks

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_policy,
    # aws_iam_role_policy.ecs_exec_permissions
  ]
}

# Security group for ECS task (allows inbound on container port)
resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg-${var.environment_name}"
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.docker_container_port
    to_port     = var.docker_container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "ecs-cluster-${var.environment_name}"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${var.environment_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_role_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.sqs_read_write_policy.arn
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.app_name}-task-${var.environment_name}" # A unique name for your task definition
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
  # Used by ECS to pull images, push logs, decrypt secrets, etc.
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # ARN of IAM role that used by your container app code (inside the task) to access other AWS services like SQS, S3, DynamoDB
  task_role_arn           = aws_iam_role.ecs_task_role.arn


  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-${var.environment_name}"
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.docker_image_name}"
      cpu       = var.task_cpu
      memory    = var.task_memory
      essential = true
      portMappings = [
        {
          containerPort = var.docker_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SQS_URL"
          value = var.sqs_main_url
        },
        {
          name  = "SQS_URL2"
          value = "${var.sqs_main_url}-2"
        }
      ]
      #  See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specify-log-config.html
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "aws-ecs-logs-example"
        }
      }
    }
  ])

  tags = {
    Environment = var.environment_name
  }
}


resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = local.ecs_cloud_watch_log_group_name
  retention_in_days = 3 # optional
  skip_destroy = true

  tags = {
    Environment = var.environment_name
  }
}
