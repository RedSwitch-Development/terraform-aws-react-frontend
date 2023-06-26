output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website_cdn.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website_cdn.id
}

output "s3_bucket_frontend_domain_name" {
  value = aws_s3_bucket.website_bucket.bucket_domain_name
}