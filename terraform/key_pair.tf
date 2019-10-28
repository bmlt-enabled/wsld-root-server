resource aws_key_pair ssh {
  key_name_prefix = "jonathan-${terraform.workspace}-"
  public_key      = file("~/.ssh/id_rsa.pub")
}
