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