## required variable input

variable "website_domain" {
  description = "The domain of the website to create"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
}


## optional variable input

# optional acm cert configuration
variable "create_acm_certificate" {
  description = "Whether to enable creation of an ACM certificate"
  type        = bool
  default     = true
}

# required if acm cert creation is disabled
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the CloudFront distribution"
  type        = string
  default     = ""
}

# optional website configuration
variable "website_index_document" {
  description = "The index document of the website"
  type        = string
  default     = "index.html"
}

# optional bucket configuration
variable "enable_access_log_bucket" {
  description = "Whether to enable access logging for the bucket"
  type        = bool
  default     = false
}

variable "access_log_bucket_name" {
  description = "The name of the bucket to use for access logs"
  type        = string
  # will default to the bucket name with "-access-logs" appended if unspecified
  default = ""
}

variable "access_log_target_prefix" {
  description = "The prefix for the access logs"
  type        = string
  default     = "access-logs/"
}

variable "bucket_force_destroy" {
  description = "Whether to force destroy the bucket"
  type        = bool
  default     = false
}

# optional cloudfront configuration
variable "extra_cloudfront_aliases" {
  description = "Extra CloudFront aliases to add to the distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_custom_error_responses" {
  type = list(object({
    error_code            = number
    response_page_path    = string
    response_code         = optional(number, null)
    error_caching_min_ttl = optional(number, null)
  }))
  default = []
}

variable "cloudfront_price_class" {
  description = "The price class of the CloudFront distribution"
  type        = string
  default     = "PriceClass_All"
}

variable "cloudfront_wait_for_deployment" {
  description = "Whether to wait for the CloudFront distribution to be deployed"
  type        = bool
  # default to false to minimize runtime of terraform
  default = false
}

variable "cloudfront_cache_behavior_min_ttl" {
  type    = number
  default = 0
}

variable "cloudfront_cache_behavior_default_ttl" {
  type    = number
  default = 600
}

variable "cloudfront_cache_behavior_max_ttl" {
  type    = number
  default = 3600
}

variable "cloudfront_minimum_protocol_version" {
  description = "The minimum TLS protocol version for the CloudFront distribution"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "cloudfront_ssl_support_method" {
  description = "The SSL support method for the CloudFront distribution"
  type        = string
  default     = "sni-only"
}

variable "cloudfront_default_cache_behavior_allowed_methods" {
  description = "The allowed methods for the default cache behavior of the CloudFront distribution"
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cloudfront_default_cache_behavior_cached_methods" {
  description = "The cached methods for the default cache behavior of the CloudFront distribution"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cloudfront_restriction_type" {
  description = "The restriction type for the CloudFront distribution"
  type        = string
  default     = "none"
}

variable "website_content_filepath" {
  description = "The file paths for all files to upload to the website. Enables management of the website content"
  type        = string
  default     = ""
}

variable "enable_cloudfront_invalidation" {
  description = "Whether to enable automatic CloudFront invalidation on file uploads"
  type        = bool
  default     = false
}

variable "cloudfront_invalidation_environment" {
  description = "Environment variable map for configuring the AWS CLI to invalidate the CloudFront distribution"
  type        = map(string)
  default     = {}
}

# optional route53 configuration
variable "create_hosted_zone" {
  description = "Whether to enable creation of a Route53 hosted zone. By default it assumes the hosted zone already exists"
  type        = bool
  default     = false
}

variable "hosted_zone_name" {
  description = "The name of the Route53 hosted zone to create or find"
  type        = string
  default     = ""
}

variable "create_site_records" {
  description = "Whether to enable creation of the Route53 records for the website"
  type        = bool
  default     = true
}

# optional tags
variable "tags" {
  description = "Tags to add to all resources"
  type        = map(string)
  default     = {}
}
