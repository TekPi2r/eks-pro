# Variables/locals communs (si pas déjà présents)
locals {
  project = "eks-pro"
  env     = "dev"

  state_bucket_name = "eks-pro-dev-tfstate"       # = backend.hcl bucket
  lock_table_name   = "eks-pro-dev-tf-lock"       # = backend.hcl dynamodb_table
  kms_alias_name    = "alias/eks-pro-dev-tfstate" # alias pratique pour la CMK du state
}

# Résolution des ARNs (évite les placeholders)
data "aws_s3_bucket" "state" { bucket = local.state_bucket_name }
data "aws_dynamodb_table" "lock" { name = local.lock_table_name }
data "aws_kms_key" "state" { key_id = local.kms_alias_name } # ou l’ARN direct si tu préfères

module "gh_oidc_plan" {
  source         = "../modules/gh_oidc_plan"
  project        = local.project
  env            = local.env
  repo_full_name = "TekPi2r/eks-pro"

  # On passe des ARNs fiables issus des data sources
  tfstate_bucket_arn = data.aws_s3_bucket.state.arn
  tf_lock_table_arn  = data.aws_dynamodb_table.lock.arn
  tfstate_kms_arn    = data.aws_kms_key.state.arn

  name_prefix = "${local.project}-${local.env}"
}

output "oidc_provider_arn" { value = module.gh_oidc_plan.oidc_provider_arn }
output "gha_tf_plan_role_arn" { value = module.gh_oidc_plan.gha_tf_plan_role_arn }
