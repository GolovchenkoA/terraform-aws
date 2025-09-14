output "sqs_instance" {
  description = "Created SQS instance"
  value = <<EOT
Created SQS Instance:
SQS: ${aws_sqs_queue.simple_sqs_001.arn}
SQS DLQ: ${aws_sqs_queue.dlq.arn}

How to send a message from the EC2 instance:
aws sqs send-message --queue-url ${aws_sqs_queue.simple_sqs_001.url} --message-body "Hello from EC2" --region ${var.aws_region}

How to read messages from the EC2 instance:
aws sqs receive-message --queue-url ${aws_sqs_queue.simple_sqs_001.url} --message-body "Hello from EC2" --region ${var.aws_region} --max-number-of-messages 5
EOT
}

output "ec2_sqs_role_name" {
  value = aws_iam_role.sqs_read_write_role.name
}

output "sqs_main_url" {
  value = aws_sqs_queue.simple_sqs_001.url
}
