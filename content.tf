locals {
  # content type conversion map, to override s3 content type using file extension
  content_types = {
    "css"  = "text/css"
    "eot"  = "application/vnd.ms-fontobject"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "jpg"  = "image/jpeg"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
    "ttf"  = "font/ttf"
    "txt"  = "text/plain"
    "webp" = "image/webp"
    "woff" = "font/woff"
  }
}

locals {
  # fileset fails if provided an empty string, so we need to check for that and
  # give it a bogus path to ensure that terraform doesn't freeze
  website_content_filepath = var.website_content_filepath != "" ? var.website_content_filepath : path.module
  website_content_files = var.website_content_filepath != "" ? fileset("${local.website_content_filepath}/", "**") : []
}

# content for the website
resource "aws_s3_object" "content" {
  for_each     = local.website_content_files
  provider     = aws.main
  bucket       = aws_s3_bucket.website.id
  key          = each.value
  source       = "${var.website_content_filepath}/${each.value}"
  content_type = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  etag         = filemd5("${var.website_content_filepath}/${each.value}")
}

locals {
  # combine all of the hashes into one, so we can use it to determine when to
  # invalidate the cloudfront cache
  object_hashes = join("", [for object in aws_s3_object.content : object.etag])
  combined_hash = sha256(local.object_hashes)
}

# null resource for invalidating the cloudfront cache when s3 objects are
# updated. uses a null reosurce because the aws terraform provider does not
# support a way to create cache invalidations
resource "null_resource" "cloudfront_invalidation" {
  count = var.enable_cloudfront_invalidation ? 1 : 0

  triggers = {
    # trigger the invalidation when the hash of the content changes
    content_hash = local.combined_hash
  }

  provisioner "local-exec" {
    command     = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.website.id} --paths '/*'"
    environment = var.cloudfront_invalidation_environment
  }
}
