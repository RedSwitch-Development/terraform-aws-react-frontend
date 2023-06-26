resource "aws_s3_bucket" "website_bucket" {
  bucket = var.service_name

  tags = {
    Service     = var.service_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket,
    aws_s3_bucket_public_access_block.website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for ${var.service_name}"
  default_root_object = "index.html"
  aliases             = [var.frontend_url]

  default_cache_behavior {
    allowed_methods = [
      "GET",
    "HEAD"]

    cached_methods = [
      "GET",
    "HEAD"]

    target_origin_id       = aws_s3_bucket.website_bucket.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "all"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.bucket_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 86400
    response_page_path    = "/index.html"
    response_code         = 200
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 86400
    response_page_path    = "/index.html"
    response_code         = 200
  }

  tags = {
    Service     = var.service_name
    Environment = var.environment
  }
}
