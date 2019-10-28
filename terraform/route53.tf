data aws_route53_zone bmltenabled {
  name = "bmltenabled.org."
}

resource aws_route53_record wsld_root_server {
  zone_id = data.aws_route53_zone.bmltenabled.zone_id
  name    = "wsld.${data.aws_route53_zone.bmltenabled.name}"
  type    = "A"
  ttl     = 60
  records = [module.bmlt_root_server.root_server_ip]
}

resource aws_route53_record wsld_root_server_db {
  zone_id = data.aws_route53_zone.bmltenabled.zone_id
  name    = "wsld-db.${data.aws_route53_zone.bmltenabled.name}"
  type    = "CNAME"
  ttl     = 60
  records = [module.bmlt_root_server.database_hostname]
}
