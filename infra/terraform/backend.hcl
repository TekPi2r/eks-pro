#############################################
# Remote backend for Terraform (dev)
# - Uses PoC 1A resources (S3 + DDB + KMS)
# - Change "key" per stack (here: iam-oidc)
#############################################

bucket         = "eks-pro-dev-tfstate"
key            = "infra.tfstate"
region         = "eu-west-3"
dynamodb_table = "eks-pro-dev-tf-lock"
kms_key_id     = "arn:aws:kms:eu-west-3:325107200902:alias/eks-pro-dev-tfstate"
encrypt        = true
