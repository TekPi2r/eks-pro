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
