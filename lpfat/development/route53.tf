locals {
  records = {
    for name in local.domains_name :
    name => regex("^(?P<host>[^\\.]+)\\.(?P<domain>.+)$", name)
  }
}

resource "aws_route53_record" "route53_record" {
  for_each = local.records

  zone_id  = data.aws_route53_zone.internal_zone.id
  name     = each.value.host
  type     = "CNAME"
  ttl      = 300
  provider = aws.route53-zone-internal
  records  = [module.aws_alb_lpfat.dns_name]
}
