# s3.tf

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# The main bucket for secure document uploads
resource "aws_s3_bucket" "main_bucket" {
  bucket = "project-guardian-uploads-${random_string.bucket_suffix.result}"

  # Block all public access - CRITICAL for security
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "main_bucket_pab" {
  bucket = aws_s3_bucket.main_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "main_bucket_sse" {
  bucket = aws_s3_bucket.main_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  bucket = aws_s3_bucket.main_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# A separate bucket for suspicious files
resource "aws_s3_bucket" "quarantine_bucket" {
  bucket        = "project-guardian-quarantine-${random_string.bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "quarantine_bucket_pab" {
  bucket = aws_s3_bucket.quarantine_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}