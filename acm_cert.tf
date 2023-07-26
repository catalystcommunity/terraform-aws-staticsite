resource "aws_acm_certificate" "cert" {
  count                     = var.create_acm_certificate ? 1 : 0
  provider                  = aws.acm
  domain_name               = var.website_domain
  subject_alternative_names = var.extra_cloudfront_aliases
  validation_method         = "DNS"
  tags                      = var.tags
}

locals {
  domain_validation_options = var.create_acm_certificate ? aws_acm_certificate.cert[0].domain_validation_options : []
}

resource "aws_route53_record" "validation_records" {
  for_each = {
    for dvo in local.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  provider        = aws.main
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = local.hosted_zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.create_acm_certificate ? 1 : 0
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.cert[count.index].arn
  validation_record_fqdns = [for record in aws_route53_record.validation_records : record.fqdn]

  depends_on = [
    aws_acm_certificate.cert,
    aws_route53_record.validation_records,
  ]
}
