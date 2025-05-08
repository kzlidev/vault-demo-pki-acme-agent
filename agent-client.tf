resource "aws_eip" "agent_public" {
  domain   = "vpc"
  instance = aws_instance.agent_server.id
}

locals {
  agent_user_data = templatefile("${path.module}/templates/agent-userdata.sh.tftpl", {
    ca_cert          = var.ca_cert
    approle_roleid   = vault_approle_auth_backend_role.pki_agent_app_role.role_id
    approle_secretid = vault_approle_auth_backend_role_secret_id.id.secret_id
    client_name      = var.agent_client_dns
    vault_addr       = var.vault_addr
    agent_config     = templatefile("${path.module}/templates/agent.hcl.tftpl", {
      vault_addr  = var.vault_addr
      client_name = var.agent_client_dns
    })
  })
}

resource "aws_instance" "agent_server" {
  ami           = var.ami_id  # Use a valid AMI for your region
  instance_type = "t2.micro"

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  tags = {
    Name = "AgentDemoServer"
  }

  user_data = local.agent_user_data
}

resource "aws_route53_record" "vault_agent_pki" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.agent_client_dns
  type    = "A"
  ttl     = 300
  records = [aws_eip.agent_public.public_ip]
}

resource "local_file" "agent_user_data" {
  filename = "${path.module}/tmp/agent-user-data.sh"
  content  = local.agent_user_data
}