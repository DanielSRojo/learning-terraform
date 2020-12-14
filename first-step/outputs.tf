output "server-public-ip" {
  value = aws_eip.one.public_ip
}

output "server-open-ports" {
  value = aws_security_group.allow_web.ingress.*.from_port
}
