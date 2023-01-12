data "aws_iam_policy_document" "s3-website-policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]

    principals {
      identifiers = ["*"]
      type = "AWS"
    }

    resources = [
      "arn:aws:s3:::${var.service_name}/*"
    ]
  }
}

resource "aws_s3_bucket" "website-bucket" {
  bucket = var.service_name
  acl    = "public-read"
  policy = data.aws_iam_policy_document.s3-website-policy.json

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Service        = var.service_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "website-bucket-access-control" {
  bucket             = aws_s3_bucket.website-bucket.id
  block_public_acls  = false
  ignore_public_acls = false
}

resource "aws_cloudfront_distribution" "website-cdn" {
  enabled = true
  is_ipv6_enabled = true
  comment = "CDN for ${var.service_name}"
  default_root_object = "index.html"
  aliases = [var.frontend_url]

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD"]

    cached_methods = [
      "GET",
      "HEAD"]

    target_origin_id = aws_s3_bucket.website-bucket.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "all"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.website-bucket.bucket_regional_domain_name
    origin_id = aws_s3_bucket.website-bucket.bucket_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    ssl_support_method = "sni-only"
  }

  custom_error_response {
    error_code = 404
    error_caching_min_ttl = 86400
    response_page_path = "/index.html"
    response_code = 200
  }

  custom_error_response {
    error_code = 403
    error_caching_min_ttl = 86400
    response_page_path = "/index.html"
    response_code = 200
  }

  tags = {
    Service        = var.service_name
    Environment = var.environment
  }
}
