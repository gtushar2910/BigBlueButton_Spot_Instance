
output "vpc_id" {
  value = aws_vpc.prod-vpc.id
}

output "subnet_id" {
  value = aws_subnet.subnet-1.id
}

output "gateway" {
  value = aws_internet_gateway.gw
}

