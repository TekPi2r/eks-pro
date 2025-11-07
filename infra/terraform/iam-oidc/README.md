# IAM OIDC for GitHub Actions — 1C.A (plan only)

Purpose: create the GitHub OIDC provider + a minimal role (`gha-tf-plan`) that can only read/write the Terraform remote state (S3/DDB/KMS). No infra creation yet.

## How

Fill `../backend.hcl`, then:

```bash
cd infra/terraform/iam-oidc
terraform init -backend-config=../backend.hcl
terraform apply \
  -var 'project=eks-pro' \
  -var 'env=dev' \
  -var 'aws_region=eu-west-3' \
  -var 'github_owner=<your-gh-user>' \
  -var 'github_repo=eks-pro' \
  -var 'tfstate_bucket_arn=arn:aws:s3:::<eks-pro-dev-tfstate>' \
  -var 'tf_lock_table_arn=<arn:aws:dynamodb:...:table/<eks-pro-dev-tf-lock>>' \
  -var 'tfstate_kms_arn=<arn:aws:kms:...:key/...>'
```
