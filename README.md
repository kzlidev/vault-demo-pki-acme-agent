# Vault PKI Demo 

## Introduction
This demo is built on top of the HashiCorp `terraform-aws-vault-enterprise-hvd` module that can be found here: https://github.com/hashicorp/terraform-aws-vault-enterprise-hvd/tree/main 



We can use the openssl library to validate the issued leaf cert. 

The trust store for openssl if installed with homebrew is at: /opt/homebrew/etc/openssl@3/cert.pem 

To validate leaf cert use 
```bash
openssl verify -untrusted ./tmp/ca_chain.pem ./tmp/client.pem
```
 - ca_chain is the returned issuer 

In general it should be:
1. If root CA cert is trusted, leaf cert should be trusted 
2. If root CA cert is not trusted (i.e., not in cert.pem), leaf cert should not be trusted. 

