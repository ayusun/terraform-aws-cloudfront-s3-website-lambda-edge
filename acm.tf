resource "aws_acm_certificate" "assets" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_name
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

}

resource "aws_acm_certificate_validation" "validation_record_acm_certificate_assets" {
  certificate_arn = aws_acm_certificate.assets.arn
  validation_record_fqdns = [
    for validation_option in aws_acm_certificate.assets.domain_validation_options :
    trimsuffix(validation_option.resource_record_name, ".")
  ]
}

# Validates the ACM wildcard by creating a Route53 record (as `validation_method` is set to `DNS` in the aws_acm_certificate resource)
resource "aws_route53_record" "web_validation" {
  for_each = {
    for dvo in aws_acm_certificate.assets.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name            = each.value.name
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain_name.zone_id
  records         = [each.value.record]
  allow_overwrite = true
  ttl             = "60"
}