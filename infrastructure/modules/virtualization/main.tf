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

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "Ec2InstanceProfile"
  role =  var.ec2_instance_role_name
}

####################### ECS #######################

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

#  Policy required to enable ECS Exec  aws_ecs_service. See: enable_execute_command = true
# resource "aws_iam_role_policy" "ecs_exec_permissions" {
#   name = "ecsExecPermissions"
#   role = aws_iam_role.ecs_task_execution_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ssmmessages:CreateControlChannel",
#           "ssmmessages:CreateDataChannel",
#           "ssmmessages:OpenControlChannel",
#           "ssmmessages:OpenDataChannel"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.app_name}-task-${var.environment_name}" # A unique name for your task definition
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn


  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-${var.environment_name}"
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.docker_image_name}"
      essential = true
      portMappings = [
        {
          containerPort = var.docker_container_port
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Environment = var.environment_name
  }
}
