variable "project" { type = string }
variable "env" { type = string }
variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

# GitHub repo that will assume the role
variable "github_owner" { type = string } # e.g., "TekPi2r"
variable "github_repo" { type = string }  # e.g., "eks-pro"

# Remote state resources from PoC 1A
variable "tfstate_bucket_arn" { type = string }
variable "tf_lock_table_arn" { type = string }
variable "tfstate_kms_arn" { type = string }
