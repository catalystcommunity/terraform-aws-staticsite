# terraform-aws-staticsite

This module provisions a static site in AWS. It makes use of several AWS
services including S3, CloudFront, ACM and Route53. ACM certificate and Route53
DNS record creation are optional so that this module can fit your needs.

Two AWS providers are required for deploying this module, as AWS ACM requires
the us-east-1 region. See examples on how to specify providers.

## Example Implementation

### Basic

This will deploy the module with ACM and Route53 enabled. It assumes that a
Route53 zone already exists.

```terraform
provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}

module "static-site" {
  source = "github.com/catalystsquad/terraform-aws-staticsite"

  # required arguments
  website_domain = "example.com"
  bucket_name    = "example.com"
  
  # optional arguments
  website_content_filepath = "./dist"
  
  providers = {
    aws.main = aws
    aws.acm  = aws.acm
  }
}
```


### CloudFront Invalidation

This module implements a method of invalidating the CloudFront cache to ensure
that new files are pushed out to edge locations. It makes use of the AWS CLI,
because the AWS terraform provider does not implement CloudFront invalidation.
A configuration variable `cloudfront_invalidation_environment` is available for
you to configure the AWS CLI to ensure that it ends up with the same
configuration as your AWS provider.
```terraform
provider "aws" {
  region  = "us-west-2"
  profile = "environment_1"
}

provider "aws" {
  region  = "us-east-1"
  profile = "environment_1"
  alias   = "acm"
}

module "static-site" {
  source = "github.com/catalystsquad/terraform-aws-staticsite"
  
  enable_cloudfront_invalidation = true
  cloudfront_invalidation_environment = {
    AWS_PROFILE = "environment_1"
  }
  
  # other variable input and provider configuration ...
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_bucket_name"></a> [access\_log\_bucket\_name](#input\_access\_log\_bucket\_name) | The name of the bucket to use for access logs | `string` | `""` | no |
| <a name="input_access_log_target_prefix"></a> [access\_log\_target\_prefix](#input\_access\_log\_target\_prefix) | The prefix for the access logs | `string` | `"access-logs/"` | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | The ARN of the ACM certificate to use for the CloudFront distribution | `string` | `""` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | Whether to force destroy the bucket | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket to create | `string` | n/a | yes |
| <a name="input_cloudfront_cache_behavior_default_ttl"></a> [cloudfront\_cache\_behavior\_default\_ttl](#input\_cloudfront\_cache\_behavior\_default\_ttl) | n/a | `number` | `600` | no |
| <a name="input_cloudfront_cache_behavior_max_ttl"></a> [cloudfront\_cache\_behavior\_max\_ttl](#input\_cloudfront\_cache\_behavior\_max\_ttl) | n/a | `number` | `3600` | no |
| <a name="input_cloudfront_cache_behavior_min_ttl"></a> [cloudfront\_cache\_behavior\_min\_ttl](#input\_cloudfront\_cache\_behavior\_min\_ttl) | n/a | `number` | `0` | no |
| <a name="input_cloudfront_custom_error_responses"></a> [cloudfront\_custom\_error\_responses](#input\_cloudfront\_custom\_error\_responses) | n/a | <pre>list(object({<br>    error_code            = number<br>    response_page_path    = string<br>    response_code         = optional(number, null)<br>    error_caching_min_ttl = optional(number, null)<br>  }))</pre> | `[]` | no |
| <a name="input_cloudfront_default_cache_behavior_allowed_methods"></a> [cloudfront\_default\_cache\_behavior\_allowed\_methods](#input\_cloudfront\_default\_cache\_behavior\_allowed\_methods) | The allowed methods for the default cache behavior of the CloudFront distribution | `list(string)` | <pre>[<br>  "DELETE",<br>  "GET",<br>  "HEAD",<br>  "OPTIONS",<br>  "PATCH",<br>  "POST",<br>  "PUT"<br>]</pre> | no |
| <a name="input_cloudfront_default_cache_behavior_cached_methods"></a> [cloudfront\_default\_cache\_behavior\_cached\_methods](#input\_cloudfront\_default\_cache\_behavior\_cached\_methods) | The cached methods for the default cache behavior of the CloudFront distribution | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_invalidation_environment"></a> [cloudfront\_invalidation\_environment](#input\_cloudfront\_invalidation\_environment) | Environment variable map for configuring the AWS CLI to invalidate the CloudFront distribution | `map(string)` | `{}` | no |
| <a name="input_cloudfront_minimum_protocol_version"></a> [cloudfront\_minimum\_protocol\_version](#input\_cloudfront\_minimum\_protocol\_version) | The minimum TLS protocol version for the CloudFront distribution | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | The price class of the CloudFront distribution | `string` | `"PriceClass_All"` | no |
| <a name="input_cloudfront_restriction_type"></a> [cloudfront\_restriction\_type](#input\_cloudfront\_restriction\_type) | The restriction type for the CloudFront distribution | `string` | `"none"` | no |
| <a name="input_cloudfront_ssl_support_method"></a> [cloudfront\_ssl\_support\_method](#input\_cloudfront\_ssl\_support\_method) | The SSL support method for the CloudFront distribution | `string` | `"sni-only"` | no |
| <a name="input_cloudfront_wait_for_deployment"></a> [cloudfront\_wait\_for\_deployment](#input\_cloudfront\_wait\_for\_deployment) | Whether to wait for the CloudFront distribution to be deployed | `bool` | `false` | no |
| <a name="input_create_acm_certificate"></a> [create\_acm\_certificate](#input\_create\_acm\_certificate) | Whether to enable creation of an ACM certificate | `bool` | `true` | no |
| <a name="input_create_hosted_zone"></a> [create\_hosted\_zone](#input\_create\_hosted\_zone) | Whether to enable creation of a Route53 hosted zone. By default it assumes the hosted zone already exists | `bool` | `false` | no |
| <a name="input_create_site_records"></a> [create\_site\_records](#input\_create\_site\_records) | Whether to enable creation of the Route53 records for the website | `bool` | `true` | no |
| <a name="input_enable_access_log_bucket"></a> [enable\_access\_log\_bucket](#input\_enable\_access\_log\_bucket) | Whether to enable access logging for the bucket | `bool` | `false` | no |
| <a name="input_enable_cloudfront_invalidation"></a> [enable\_cloudfront\_invalidation](#input\_enable\_cloudfront\_invalidation) | Whether to enable automatic CloudFront invalidation on file uploads | `bool` | `false` | no |
| <a name="input_extra_cloudfront_aliases"></a> [extra\_cloudfront\_aliases](#input\_extra\_cloudfront\_aliases) | Extra CloudFront aliases to add to the distribution | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_website_content_filepath"></a> [website\_content\_filepath](#input\_website\_content\_filepath) | The file paths for all files to upload to the website. Enables management of the website content | `string` | `""` | no |
| <a name="input_website_domain"></a> [website\_domain](#input\_website\_domain) | The domain of the website to create | `string` | n/a | yes |
| <a name="input_website_index_document"></a> [website\_index\_document](#input\_website\_index\_document) | The index document of the website | `string` | `"index.html"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | n/a |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | n/a |
| <a name="output_cloudfront_zone_id"></a> [cloudfront\_zone\_id](#output\_cloudfront\_zone\_id) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.validation_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_logging.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.logs_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs_block_public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_object.content](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.cloudfront_invalidation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudfront_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_access_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
<!-- END_TF_DOCS -->
