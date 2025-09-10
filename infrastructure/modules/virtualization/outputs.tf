output "ec2_instance" {
  description = "Created EC2 instance"
  value = <<EOT
  Created EC2 Instance:
  Type: ${aws_instance.ec2_instance_001.instance_type}
  AMI: ${aws_instance.ec2_instance_001.ami}
  URN: ${aws_instance.ec2_instance_001.arn}
EOT
}