provider "aws" {
  region = "us-east-1" # Change to your region
}

# 1. SNS Topic for Notifications
resource "aws_sns_topic" "cpu_alerts" {
  name = "ec2-cpu-utilization-alerts"
}

# 2. SNS Email Subscription
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cpu_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}


# 3. CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "High-CPU-Utilization-EC2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3 #  The number of periods over which data is compared to the specified threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 3600 # The period in seconds over which the specified statistic is applied.
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert if EC2 CPU utilization > 0% for 3 hours"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.cpu_alerts.arn]
  # ok_actions          = [aws_sns_topic.cpu_alerts.arn]

  # Optional: Limit to specific EC2 instance
  # dimensions = {
  #   InstanceId = "i-0123456789abcdef0" # <- CHANGE THIS
  # }
}
