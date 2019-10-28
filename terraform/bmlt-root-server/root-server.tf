data aws_ami ubuntu {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource aws_instance root_server {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.nano"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.root_server.id]
  iam_instance_profile   = aws_iam_instance_profile.root_server.name

  user_data = <<EOF
#!/bin/bash

apt update
apt upgrade -y
apt install -y software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt update -y
apt upgrade -y
apt install -y \
  apache2 \
  php \
  libapache2-mod-php \
  php-mcrypt php-mysql \
  php-dom \
  php-curl \
  php-gd \
  php-zip \
  php-mbstring \
  mysql-client \
  python3-pip \
  python3-certbot-apache \
  unzip
certbot \
  run \
  --apache \
  -d wsld.bmltenabled.org \
  -m 'jon.braswell@gmail.com' \
  --agree-tos \
  --non-interactive \
  --server https://acme-v02.api.letsencrypt.org/directory
wget https://github.com/bmlt-enabled/bmlt-root-server/releases/download/2.14.2/bmlt-root-server.zip
unzip bmlt-root-server.zip
rm -f bmlt-root-server.zip
mv main_server /var/www/html/main_server
rm -f /var/www/html/index.html
EOF

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "wsld-root-server-${var.environment}"
  }
}

resource aws_eip root_server {
  vpc = true
}

resource aws_eip_association root_server {
  instance_id   = aws_instance.root_server.id
  allocation_id = aws_eip.root_server.id
}

resource aws_security_group root_server {
  name   = "wsld-root-server-${var.environment}"
  vpc_id = var.vpc_id
}

resource aws_security_group_rule root_server_ingress_ssh {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.root_server.id
}

resource aws_security_group_rule root_server_ingress_http {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.root_server.id
}

resource aws_security_group_rule root_server_ingress_https {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.root_server.id
}

resource aws_security_group_rule root_server_ingress_egress {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.root_server.id
}

data aws_iam_policy_document assume_role_policy_ec2 {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document route53 {
  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZones", "route53:GetChange"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.route53_zone_id}"]
  }
}

resource aws_iam_role root_server {
  name               = "wsld-root-server-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ec2.json
}

resource aws_iam_role_policy route53 {
  name   = "wsld-root-server-${var.environment}"
  role   = aws_iam_role.root_server.id
  policy = data.aws_iam_policy_document.route53.json
}

resource aws_iam_instance_profile root_server {
  name = "wsld-root-server-${var.environment}"
  role = aws_iam_role.root_server.name
}
