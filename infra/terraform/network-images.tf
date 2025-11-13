locals {
  project = "eks-pro"
  env     = "dev"
  region  = "eu-west-3"
}

module "vpc" {
  source  = "./modules/vpc"
  project = local.project
  env     = local.env
  region  = local.region

  vpc_cidr   = "10.0.0.0/16"
  az_count   = 3
  enable_nat = true # 1 NAT, cost-optimized (note in journal)
}

module "ecr_app" {
  source  = "./modules/ecr"
  project = local.project
  env     = local.env

  repository_name        = "app"
  image_tag_immutability = "IMMUTABLE"
  scan_on_push           = true
  retain_images          = 10
  kms_key_arn            = "arn:aws:kms:eu-west-3:325107200902:alias/eks-pro-dev-tfstate" # Copy from your backend.hcl
}

output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnets" { value = module.vpc.public_subnet_ids }
output "private_subnets" { value = module.vpc.private_subnet_ids }
output "ecr_app_url" { value = module.ecr_app.repository_url }
