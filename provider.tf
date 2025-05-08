provider "vault" {
  address = var.vault_addr
}

provider "aws" {
  region = var.region
}