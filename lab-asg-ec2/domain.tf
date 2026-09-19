data "cloudflare_zone" "this" {
  filter = {
    name = local.fqdn
  }
}

resource "cloudflare_dns_record" "web" {
  zone_id = data.cloudflare_zone.this.id
  name    = "web.${local.fqdn}"
  type    = "CNAME"
  content = aws_lb.this.dns_name
  proxied = false
  ttl     = 1
}

resource "aws_acm_certificate" "this" {
  domain_name       = "web.${local.fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.this.domain_validation_options :
    option.domain_name => {
      name    = option.resource_record_name
      type    = option.resource_record_type
      content = option.resource_record_value
    }
  }

  zone_id = data.cloudflare_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  proxied = false
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for record in cloudflare_dns_record.certificate_validation :
    record.name
  ]
}
