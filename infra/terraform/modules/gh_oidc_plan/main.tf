locals {
  name_prefix = coalesce(var.name_prefix, "${var.project}-${var.env}")
  role_name   = coalesce(var.role_name, "${local.name_prefix}-gha-tf-plan")
}

#############################################
# IAM OIDC for GitHub Actions + minimal "plan" role
#############################################

# --- GitHub OIDC provider (well-known) ---
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # Thumbprint stable pour GitHub OIDC
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# --- Trust policy for GitHub Actions (any ref of this repo) ---
data "aws_iam_policy_document" "gha_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo_full_name}:*"]
    }
  }
}

# --- Minimal policy: Terraform remote state only (S3/DDB/KMS) ---
data "aws_iam_policy_document" "tfstate_rw" {
  statement {
    sid       = "S3StateBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [var.tfstate_bucket_arn]
  }

  statement {
    sid    = "S3StateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
      "s3:GetObjectVersion", "s3:DeleteObjectVersion"
    ]
    resources = ["${var.tfstate_bucket_arn}/*"]
  }

  statement {
    sid    = "DDBLock"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:GetItem",
      "dynamodb:PutItem", "dynamodb:DeleteItem"
    ]
    resources = [var.tf_lock_table_arn]
  }

  # S3 objets chiffrés CMK: autoriser encrypt/decrypt pour backend I/O
  statement {
    sid       = "KMSForState"
    effect    = "Allow"
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
    resources = [var.tfstate_kms_arn]
  }

  statement {
    sid       = "OidcRead"
    effect    = "Allow"
    actions   = ["iam:GetOpenIDConnectProvider"]
    resources = [aws_iam_openid_connect_provider.github.arn]
  }
}

resource "aws_iam_policy" "tfstate_rw" {
  name        = "${local.name_prefix}-gha-tfstate-rw"
  description = "RW on Terraform remote state (S3/DDB/KMS) for gha-tf-plan."
  policy      = data.aws_iam_policy_document.tfstate_rw.json
  tags = {
    Project = var.project
    Env     = var.env
    Purpose = "gha-tfstate-rw"
  }
}

# --- Role used by GitHub Actions to run terraform init/plan only ---
resource "aws_iam_role" "gha_tf_plan" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.gha_assume_role.json
  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_iam_role_policy_attachment" "gha_tf_plan_attach" {
  role       = aws_iam_role.gha_tf_plan.name
  policy_arn = aws_iam_policy.tfstate_rw.arn
}
