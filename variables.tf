variable "vault_addr" {
  type    = string
  default = "localhost:8200"
}

variable "ca_private_key_abs_path" {
  type    = string
  default = "/Users/kz.li/Projects/vault/terraform-aws-vault-enterprise-hvd/init/tmp/ca.key"
}

variable "ca_cert_abs_path" {
  type    = string
  default = "/Users/kz.li/Projects/vault/terraform-aws-vault-enterprise-hvd/init/tmp/ca.cert"
}

variable "region" {
  default = "ap-southeast-1"
}