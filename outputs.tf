output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website-cdn.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website-cdn.id
}

output "s3_bucket_frontend_domain_name" {
  value = aws_s3_bucket.website-bucket.bucket_domain_name
}