data "template_file" "script" {
  template = "${file("script.tpl")}"
  vars = {
    region        = var.region
    elasticip     = var.elasticip
    url           = var.url
    email         = var.email
    shared_secret = file("shared_secret.txt")
  }
}

resource "aws_instance" "BBBServer" {

  ami                             = var.ami
  instance_type                   = var.instance_type
  availability_zone               = var.availability_zone
  key_name                        = var.key_name
  

  network_interface {
    device_index         = 0
    network_interface_id = var.nic_id
  }

  user_data = data.template_file.script.rendered

  tags = {
    Name = "BigBlueButton_Server"
  }
}

resource "aws_route53_record" "bbb" {
  zone_id = var.zone_id
  name    = var.url
  type    = "A"
  ttl     = "300"
  records = [var.elasticip]
}
