module "gh_oidc_plan" {
  source = "../modules/gh_oidc_plan"

  project        = "eks-pro"
  env            = "dev"
  repo_full_name = "TekPi2r/eks-pro"

  # ARNs comme dans ton ancien fichier
  tfstate_bucket_arn = "arn:aws:s3:::eks-pro-dev-tfstate"
  tf_lock_table_arn  = "arn:aws:dynamodb:eu-west-3:325107200902:table/eks-pro-dev-tf-lock"
  tfstate_kms_arn    = "arn:aws:kms:eu-west-3:325107200902:key/83b302d6-9684-4228-a33c-04e83d0807b8"

  # pour reproduire exactement ton nommage
  name_prefix = "eks-pro-dev"
  # role_name = "eks-pro-dev-gha-tf-plan" # optionnel, sinon généré à partir de name_prefix
}

# Garder les mêmes outputs que ton ancien fichier
output "oidc_provider_arn" { value = module.gh_oidc_plan.oidc_provider_arn }
output "gha_tf_plan_role_arn" { value = module.gh_oidc_plan.gha_tf_plan_role_arn }
