provider "aws" {
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

data "aws_route53_zone" "domain_name" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "route53_record" {
  depends_on = [
    aws_cloudfront_distribution.s3_distribution,
  ]

  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

// Cloudfront Distro with lambda@Edge integration
resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket.s3_bucket, aws_acm_certificate.assets]

  origin {
    domain_name = "${var.domain_name}.s3.amazonaws.com"
    origin_id   = "s3-cloudfront"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  # Handling custom Origins
  dynamic "origin" {
    for_each = [for i in var.custom_origins : {
      name = i.domain_name
      id   = i.origin_id
      path = i.origin_path
    }]
    content {
      domain_name = origin.value.name
      origin_id   = origin.value.id
      origin_path = origin.value.path
      custom_origin_config {
        http_port              = "80"
        https_port             = "443"
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = concat([var.domain_name], var.subject_alternative_name)

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.folder_index_redirect.qualified_arn
      include_body = false
    }

    target_origin_id = "s3-cloudfront"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  dynamic "ordered_cache_behavior" {
    for_each = [for i in var.ordered_cache_behaviour : {
      allowed_methods        = i.allowed_methods
      target_origin_id       = i.target_origin_id
      path_pattern           = i.path_pattern
      viewer_protocol_policy = i.viewer_protocol_policy
      cache_policy_id        = i.cache_policy_id
      origin_policy_id       = i.origin_request_policy_id
    }]
    content {
      allowed_methods          = ordered_cache_behavior.value.allowed_methods
      target_origin_id         = ordered_cache_behavior.value.target_origin_id
      cached_methods           = ["HEAD", "GET", "OPTIONS"]
      path_pattern             = ordered_cache_behavior.value.path_pattern
      viewer_protocol_policy   = ordered_cache_behavior.value.viewer_protocol_policy
      compress                 = true
      cache_policy_id          = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id = ordered_cache_behavior.value.origin_policy_id
    }
  }

  price_class = "PriceClass_100"

  //Only US,Canada,Europe

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.assets.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/"
  }
  tags = var.tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.domain_name}.s3.amazonaws.com"
}
