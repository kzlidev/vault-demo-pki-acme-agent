variable "ami_id" {
  default     = "ami-01938df366ac2d954"
  description = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305"
}

variable "security_group_ids" {
  default = ["sg-0ff54ca1daf21dc48"]
}

variable "subnet_id" {
  default = "subnet-050239ff37c785c2a"
}

variable "ca_cert" {
  default = ""
}

variable "top_level_domain_name" {
  default = "localhost"
}

variable "acme_client_dns" {
  default     = "acmeweb.localhost"
  description = "DNS should be the same top_level_domain_name"
}

resource "aws_eip" "acme_public" {
  domain   = "vpc"
  instance = aws_instance.acme_server.id
}

locals {
  acme_user_data = templatefile("${path.module}/templates/userdata.sh.tftpl", {
    ca_cert               = var.ca_cert
    eab_kid               = vault_pki_secret_backend_acme_eab.test.eab_id
    eab_hmac_key          = vault_pki_secret_backend_acme_eab.test.key
    client_name           = var.acme_client_dns
    acme_server_directory = "${var.vault_addr}/v1/${local.mount_point_name}/roles/${vault_pki_secret_backend_role.trusted_ica_role.name}/acme/directory"
  })
}

resource "aws_instance" "acme_server" {
  ami           = var.ami_id  # Use a valid AMI for your region
  instance_type = "t2.micro"

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  tags = {
    Name = "AcmeDemoServer"
  }

  user_data = local.acme_user_data
}

data "aws_route53_zone" "public" {
  name = var.top_level_domain_name
}

resource "aws_route53_record" "vault_acme_pki" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.acme_client_dns
  type    = "A"
  ttl     = 300
  records = [aws_eip.acme_public.public_ip]
}

resource "local_file" "acme_user_data" {
  filename = "${path.module}/tmp/acme-user-data.sh"
  content  = local.acme_user_data
}