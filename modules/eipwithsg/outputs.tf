
output "eip_publicip" {
  value = aws_eip.one.public_ip
}

output "security_group_id" {
  value = aws_security_group.allow_web.id
}
output "nw_interface_id" {
  value = aws_network_interface.web-server_nic.id
}

