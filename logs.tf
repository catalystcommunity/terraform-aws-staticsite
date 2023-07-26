locals {
  logs_bucket_name = var.access_log_bucket_name != "" ? var.access_log_bucket_name : "${var.bucket_name}-access-logs"

}

resource "aws_s3_bucket" "logs" {
  count         = var.enable_access_log_bucket ? 1 : 0
  bucket        = local.logs_bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = var.enable_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.logs[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  count  = var.enable_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.logs[count.index].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  count      = var.enable_access_log_bucket ? 1 : 0
  bucket     = aws_s3_bucket.logs[count.index].id
  depends_on = [aws_s3_bucket_ownership_controls.logs]
  acl        = "log-delivery-write"
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html
data "aws_iam_policy_document" "logs_access_policy_document" {
  count = var.enable_access_log_bucket ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs[count.index].arn}/*", ]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:s3:::${var.bucket_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

  }
}

resource "aws_s3_bucket_policy" "logs_access_policy" {
  count  = var.enable_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.logs[count.index].id
  policy = data.aws_iam_policy_document.logs_access_policy_document[count.index].json
}

resource "aws_s3_bucket_public_access_block" "logs_block_public_access" {
  count                   = var.enable_access_log_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.logs[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
