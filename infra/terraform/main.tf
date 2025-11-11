terraform {
  required_version = ">= 1.6.0"
  backend "s3" {} # les valeurs viennent de backend.hcl
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider racine (les modules héritent)
provider "aws" {
  region = var.aws_region
}

# Appelle ton "sous-module" iam-oidc (ton caller existe déjà dedans)
module "iam_oidc" {
  source = "./iam-oidc"
}

output "oidc_provider_arn" { value = module.iam_oidc.oidc_provider_arn }
output "gha_tf_plan_role_arn" { value = module.iam_oidc.gha_tf_plan_role_arn }
