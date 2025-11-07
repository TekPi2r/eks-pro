#############################################
# Terraform state bootstrap (S3 + DynamoDB)
# - S3 bucket (versioned, KMS-encrypted, no public access)
# - S3 server access logging to a dedicated bucket (also KMS-encrypted)
# - DynamoDB lock table (PITR + KMS CMK)
# - Minimal IAM policy for using this state/lock (attach later)
#############################################

# Naming and tagging helpers so every resource inherits the same prefix and metadata.
locals {
  name_prefix = "${var.project}-${var.env}"

  # Allow explicit names via variables; else auto-name from prefix
  bucket_name = var.bucket_name != "" ? var.bucket_name : "${local.name_prefix}-tfstate"
  lock_table  = var.dynamodb_table_name != "" ? var.dynamodb_table_name : "${local.name_prefix}-tf-lock"

  tags = {
    Project = var.project
    Env     = var.env
    Owner   = "platform"
    Purpose = "terraform-state"
  }
}

#############################################
# KMS — Customer Managed Key for S3 & DynamoDB
#############################################

# One CMK powers both the state bucket encryption and the DynamoDB table SSE/PITR.
resource "aws_kms_key" "tfstate" {
  description             = "CMK for Terraform state bucket and DynamoDB lock"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "tfstate" {
  name          = "alias/${local.name_prefix}-tfstate"
  target_key_id = aws_kms_key.tfstate.key_id
}

#############################################
# S3 — State bucket (versioned, private, KMS CMK)
#############################################

# Primary Terraform state bucket; remains intentionally empty until modules store state.
resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name
  tags   = local.tags
}

# Enforce bucket-owner ownership (no ACLs)
resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Keep history of state changes
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest with customer-managed KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
  }
}

# Optional: lifecycle for non-current versions
# Down-tier and expire non-current object versions to control storage growth over time.
resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "noncurrent-cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

# S3 — Dedicated logs bucket (for server access logs)
resource "aws_s3_bucket" "tfstate_logs" {
  bucket = "${local.name_prefix}-tfstate-logs"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# ACLs must remain enabled on the logging bucket so AWS can push access logs into it.
resource "aws_s3_bucket_acl" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.tfstate_logs
  ]
}

resource "aws_s3_bucket_public_access_block" "tfstate_logs" {
  bucket                  = aws_s3_bucket.tfstate_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
  }
}

# Enable server access logging on the state bucket
resource "aws_s3_bucket_logging" "tfstate" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.tfstate_logs.id
  target_prefix = "s3-access-logs/"
}

#############################################
# DynamoDB — Lock table (PITR + KMS CMK)
#############################################

# DynamoDB table acts as the Terraform state lock; PITR + SSE harden against corruption.
resource "aws_dynamodb_table" "tf_lock" {
  name         = local.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # DynamoDB SSE with customer-managed KMS key
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tfstate.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tags
}

#############################################
# IAM — Minimal RW policy for this state & lock (attach later)
#############################################

# Policy assembled here can be attached to IAM principals that need to interact with the state backend.
data "aws_iam_policy_document" "tfstate_rw" {
  statement {
    sid    = "S3StateBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.tfstate.arn
    ]
  }

  statement {
    sid    = "S3StateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.tfstate.arn}/*"
    ]
  }

  statement {
    sid    = "DDBStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      aws_dynamodb_table.tf_lock.arn
    ]
  }
}

resource "aws_iam_policy" "tfstate_rw" {
  name        = "${local.name_prefix}-tfstate-rw"
  description = "Minimal RW permissions for Terraform remote state and lock on S3/DynamoDB."
  policy      = data.aws_iam_policy_document.tfstate_rw.json
  tags        = local.tags
}
