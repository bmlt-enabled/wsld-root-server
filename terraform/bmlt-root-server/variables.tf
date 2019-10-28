variable vpc_id {
  type = string
}

variable subnet_id {
  type = string
}

variable rds_subnet_ids {
  type = list(string)
}

variable key_name {
  type = string
}

variable rds_password {
  type = string
}

variable route53_zone_id {
  type = string
}

variable environment {
  type = string
}
