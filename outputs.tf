output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.website.id
}

output "cloudfront_zone_id" {
  value = aws_cloudfront_distribution.website.hosted_zone_id
}
