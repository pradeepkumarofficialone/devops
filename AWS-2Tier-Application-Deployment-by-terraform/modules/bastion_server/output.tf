
output "bastion_server_IP" {
  value = aws_instance.bastion_server.public_ip
}