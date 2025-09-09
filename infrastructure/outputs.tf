output "ec2_instance" {
  description = "Created EC2 instance"
  value = <<EOT
  Created EC2 Instance:
  Type: ${aws_instance.ec2_instance_001.instance_type}
  AMI: ${aws_instance.ec2_instance_001.ami}
  URN: ${aws_instance.ec2_instance_001.arn}
EOT
}

output "sqs-instance" {
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
