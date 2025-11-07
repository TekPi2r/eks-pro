#############################################
# IAM OIDC for GitHub Actions + minimal "plan" role
# - OIDC provider: token.actions.githubusercontent.com
# - Role gha-tf-plan: RW on tfstate S3/DDB + KMS decrypt (no infra create)
#############################################

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project}-${var.env}"
  repo_sub    = "repo:${var.github_owner}/${var.github_repo}:*"
}

# --- GitHub OIDC provider (well-known) ---
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # Thumbprints rotate, AWS keeps it stable behind this value; provider accepts it.
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
      values   = [local.repo_sub]
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
      "dynamodb:DescribeTable", "dynamodb:GetItem",
      "dynamodb:PutItem", "dynamodb:DeleteItem"
    ]
    resources = [var.tf_lock_table_arn]
  }
  # S3 objects are encrypted with your CMK: allow encrypt/decrypt for backend I/O
  statement {
    sid       = "KMSForState"
    effect    = "Allow"
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
    resources = [var.tfstate_kms_arn]
  }
}

resource "aws_iam_policy" "tfstate_rw" {
  name        = "${local.name_prefix}-gha-tfstate-rw"
  description = "RW on Terraform remote state (S3/DDB/KMS) for gha-tf-plan."
  policy      = data.aws_iam_policy_document.tfstate_rw.json
  tags        = { Project = var.project, Env = var.env, Purpose = "gha-tfstate-rw" }
}

# --- Role used by GitHub Actions to run terraform init/plan only ---
resource "aws_iam_role" "gha_tf_plan" {
  name               = "${local.name_prefix}-gha-tf-plan"
  assume_role_policy = data.aws_iam_policy_document.gha_assume_role.json
  tags               = { Project = var.project, Env = var.env }
}

resource "aws_iam_role_policy_attachment" "gha_tf_plan_attach" {
  role       = aws_iam_role.gha_tf_plan.name
  policy_arn = aws_iam_policy.tfstate_rw.arn
}

output "oidc_provider_arn" { value = aws_iam_openid_connect_provider.github.arn }
output "gha_tf_plan_role_arn" { value = aws_iam_role.gha_tf_plan.arn }
