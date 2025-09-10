output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "subnet_id" {
  value = aws_subnet.subnet1.id
}

output "subnet_cidr" {
  value = aws_subnet.subnet1.cidr_block
}