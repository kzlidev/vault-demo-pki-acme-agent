variable "vault_addr" {
  type    = string
  default = "localhost:8200"
}

variable "ca_private_key_abs_path" {
  type = string
}

variable "ca_cert_abs_path" {
  type = string
}

variable "region" {
  default = "ap-southeast-1"
}

variable "key_pair_name" {}

#subnet-06f3a182c113a9eb9

variable "security_group_ids" {
  description = "Security group to deploy the servers into (you can retrieve this from the hvd module)"
}

variable "subnet_id" {
  description = "Subnet to deploy the servers into (you can retrieve this from the hvd module)"
}

#variable "ca_cert" {
#  description = "Offline root CA cert"
#}
variable "top_level_domain_name" {
  default     = "localhost"
  description = "Top level domain name"
}

variable "acme_client_dns" {
  default     = "acmeweb.localhost"
  description = "Domain Name for ACME server. DNS should be the same top_level_domain_name."
}

variable "agent_client_dns" {
  default     = "agentweb.localhost"
  description = "Domain Name for Agent server. DNS should be the same top_level_domain_name."
}

variable "ami_owner" {}

variable "ami_name" {}