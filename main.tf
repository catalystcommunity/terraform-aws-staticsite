data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "website" {
  provider      = aws.main
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = var.tags
}

resource "aws_cloudfront_origin_access_control" "website" {
  provider                          = aws.main
  name                              = var.website_domain
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "cloudfront_bucket_access" {
  provider = aws.main
  statement {
    actions = [
      "s3:GetObject",
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.website.arn]
    }
    resources = [
      "${aws_s3_bucket.website.arn}/*",
    ]
  }
}

# allow cloudfront access to bucket
resource "aws_s3_bucket_policy" "website" {
  provider = aws.main
  bucket   = aws_s3_bucket.website.id
  policy   = data.aws_iam_policy_document.cloudfront_bucket_access.json
}

# lockdown bucket, only allow cloudfront to access it
resource "aws_s3_bucket_public_access_block" "website" {
  provider                = aws.main
  bucket                  = aws_s3_bucket.website.id
  ignore_public_acls      = true
  block_public_acls       = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  provider = aws.main
  bucket   = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# optionally enable access logging
resource "aws_s3_bucket_logging" "website" {
  count = var.enable_access_log_bucket ? 1 : 0

  provider      = aws.main
  bucket        = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.logs[count.index].id
  target_prefix = var.access_log_target_prefix
}

locals {
  cloudfront_aliases  = flatten([[var.website_domain], var.extra_cloudfront_aliases])
  acm_certificate_arn = var.create_acm_certificate ? aws_acm_certificate.cert[0].arn : var.acm_certificate_arn
}

resource "aws_cloudfront_distribution" "website" {
  provider            = aws.main
  enabled             = true
  comment             = var.website_domain
  aliases             = local.cloudfront_aliases
  default_root_object = var.website_index_document
  price_class         = var.cloudfront_price_class
  wait_for_deployment = var.cloudfront_wait_for_deployment
  tags                = var.tags

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = var.website_domain
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    allowed_methods  = var.cloudfront_default_cache_behavior_allowed_methods
    cached_methods   = var.cloudfront_default_cache_behavior_cached_methods
    target_origin_id = var.website_domain

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cloudfront_cache_behavior_min_ttl
    max_ttl                = var.cloudfront_cache_behavior_max_ttl
    default_ttl            = var.cloudfront_cache_behavior_default_ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = local.acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = var.cloudfront_minimum_protocol_version
    ssl_support_method             = var.cloudfront_ssl_support_method
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_restriction_type
    }
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_responses
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }
}
