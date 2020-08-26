variable "subnet_prefix"{
  description = "cidr block for subnet"
}

variable "hosted_zone_id"{
  description = "DNS Zone"
}

variable "ami"{
  description = "image id"
}

variable "region1"{
  description = "default region"
}

variable "key_name"{
  description = "SSH Key"
}

variable "email"{
  description = "email"
}

variable "private_ip_instance"{
  description = "Private IP of the Instance"
}

variable "url"{
  description = "URL"
}

provider "aws" {
   region  = "us-east-1"
   access_key = "AKIAIRC2O2TSBAYRGA3A"
   secret_key = "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"
}


resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
   tags = {
    Name = "production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = var.subnet_prefix
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "prod-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "EFS from vpc"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Big Blue Button Freeswitch"
    from_port   = 16384
    to_port     = 32768
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "web-server_nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = [var.private_ip_instance]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server_nic.id
  associate_with_private_ip = var.private_ip_instance
  depends_on = [aws_internet_gateway.gw]
}


data "template_file" "script" {
  template = "${file("script.tpl")}"
  vars = {
    region = var.region1
    elasticip = aws_eip.one.public_ip
    url = var.url
    email = var.email
  }
}


resource "aws_instance" "web-server-instance" {
  ami           = var.ami
  instance_type = "c5.xlarge"
  availability_zone = "us-east-1a"
  key_name = var.key_name

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server_nic.id 
    }
    
    user_data = data.template_file.script.rendered
   
       tags = {
      Name = "BigBlueButton_Server"
    }

}


resource "aws_route53_record" "bbb" {
  zone_id = var.hosted_zone_id
  name    = var.url
  type    = "A"
  ttl     = "300"
  records = [aws_eip.one.public_ip]
}


output "server_public_ip" {
  value = aws_eip.one.public_ip
}