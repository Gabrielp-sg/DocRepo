resource "aws_acm_certificate" "acm_internal" {
  count = length(local.domains_name)

  domain_name               = local.domains_name[count.index]
  certificate_authority_arn = local.certificate_authority_arn
  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}
