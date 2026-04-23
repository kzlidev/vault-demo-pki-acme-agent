data "aws_route53_zone" "public" {
  name = var.top_level_domain_name
}