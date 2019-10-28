output root_server_ip {
  value = aws_eip.root_server.public_ip
}

output database_hostname {
  value = aws_db_instance.root_server.address
}
