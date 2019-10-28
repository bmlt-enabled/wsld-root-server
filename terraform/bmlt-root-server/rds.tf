resource aws_db_instance root_server {
  identifier             = "wsld-root-server-${var.environment}"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "wsldrootserver${var.environment}"
  username               = "wsld"
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.root_server.id
  vpc_security_group_ids = [aws_security_group.mysql.id]
  skip_final_snapshot    = true

  tags = {
    Name = "wsld-root-server-${var.environment}"
  }
}

resource aws_db_subnet_group root_server {
  name       = "wsld-root-server-${var.environment}"
  subnet_ids = var.rds_subnet_ids

  tags = {
    Name = "wsld-root-server-${var.environment}"
  }
}

resource aws_security_group mysql {
  name_prefix = "wsld-root-server-mysql-${var.environment}"
  vpc_id      = var.vpc_id
}

resource aws_security_group_rule mysql_ingress_mysql {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.root_server.id
  security_group_id        = aws_security_group.mysql.id
}

resource aws_security_group_rule mysql_egress {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mysql.id
}
