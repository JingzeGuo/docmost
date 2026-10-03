resource "aws_acm_certificate" "docmost" {
  domain_name       = "docmost.click"
  validation_method = "DNS"

  tags = {
    Name    = "docmost.click"
    Project = "docmost"
  }
}

data "aws_route53_zone" "docmost" {
  name         = "docmost.click."
  private_zone = false
}

resource "aws_route53_record" "docmost_validation" {
  zone_id = data.aws_route53_zone.docmost.zone_id
  name    = one(aws_acm_certificate.docmost.domain_validation_options).resource_record_name
  type    = one(aws_acm_certificate.docmost.domain_validation_options).resource_record_type
  records = [one(aws_acm_certificate.docmost.domain_validation_options).resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "docmost" {
  certificate_arn         = aws_acm_certificate.docmost.arn
  validation_record_fqdns = [aws_route53_record.docmost_validation.fqdn]
}

resource "aws_route53_record" "docmost_alias" {
  zone_id = data.aws_route53_zone.docmost.zone_id
  name    = "docmost.click"
  type    = "A"

  alias {
    name                   = aws_lb.docmost.dns_name
    zone_id                = aws_lb.docmost.zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_lb_listener.https,
    aws_lb_target_group_attachment.docmost
  ]
}