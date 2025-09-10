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