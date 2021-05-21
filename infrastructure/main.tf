provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    key    = "beam-consulting/tfstate"
    region = "ap-southeast-2"
  }
}

data "aws_ssm_parameter" "hosted_zone_id" {
  name = "/private/beam_consulting/hosted_zone_id"
}

data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/private/beam_consulting/acm_certificate_arn"
}

data "aws_ssm_parameter" "cloudfront_aliases" {
  name = "/private/beam_consulting/cloudfront_aliases"
}

data "aws_route53_zone" "beam_consulting" {
  zone_id = data.aws_ssm_parameter.hosted_zone_id.value
}

resource "aws_s3_bucket" "default" {
  bucket_prefix = "beam-consulting-"
  acl           = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  lifecycle {
    ignore_changes = ["bucket_prefix"]
  }
}
//
//resource "aws_cloudfront_distribution" "default" {
//  origin {
//    domain_name = aws_s3_bucket.default.website_endpoint
//    origin_id   = "beam-consulting-origin"
//
//    custom_origin_config {
//      http_port              = 80
//      https_port             = 443
//      origin_protocol_policy = "http-only"
//      origin_ssl_protocols   = ["TLSv1.1"]
//    }
//  }
//
//  aliases = split(",", data.aws_ssm_parameter.cloudfront_aliases.value)
//
//  enabled             = true
//  is_ipv6_enabled     = true
//  default_root_object = "index.html"
//
//  default_cache_behavior {
//    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
//    cached_methods   = ["GET", "HEAD"]
//    target_origin_id = "beam-consulting-origin"
//
//    forwarded_values {
//      cookies {
//        forward = "none"
//      }
//      query_string = true
//    }
//
//    viewer_protocol_policy = "redirect-to-https"
//    max_ttl                = 86400
//    default_ttl            = 3600
//    min_ttl                = 0
//    compress               = true
//  }
//
//  price_class = "PriceClass_200"
//
//  restrictions {
//    geo_restriction {
//      restriction_type = "none"
//    }
//  }
//
//  viewer_certificate {
//    acm_certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value
//    ssl_support_method  = "sni-only"
//  }
//
//  custom_error_response {
//    error_code         = 404
//    response_code      = 404
//    response_page_path = "/404.html"
//  }
//}
//
//resource "aws_route53_record" "cf_dist" {
//  name    = data.aws_route53_zone.beam_consulting.name
//  type    = "A"
//  zone_id = data.aws_route53_zone.beam_consulting.zone_id
//
//  alias {
//    evaluate_target_health = false
//    name                   = aws_cloudfront_distribution.default.domain_name
//    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
//  }
//}

output "beam_consulting_bucket_name" {
  value = aws_s3_bucket.default.id
}
//
//output "beam_web_cloudfront_distribution_id" {
//  value = aws_cloudfront_distribution.default.id
//}
