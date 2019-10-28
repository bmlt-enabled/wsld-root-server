provider aws {
  profile = "bmlt-enabled"
  region  = "us-east-1"
}

module vpc {
  source = "terraform-aws-modules/vpc/aws"

  name = "wsld-${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}

module bmlt_root_server {
  source = "./bmlt-root-server"

  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnets[0]
  rds_subnet_ids  = module.vpc.public_subnets
  key_name        = aws_key_pair.ssh.key_name
  rds_password    = "databasepassword"
  environment     = terraform.workspace
  route53_zone_id = data.aws_route53_zone.bmltenabled.zone_id
}
