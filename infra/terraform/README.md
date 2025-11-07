# Terraform Remote Backend — Wiring

## Purpose

Reuse the **remote backend** created in **PoC 1A** (S3 state bucket + DynamoDB lock table + KMS CMK) for every Terraform stack (`vpc`, `ecr`, `eks`, `rds`, `redis`, …) through a local `backend.hcl` file that stays untracked.

## Preparing `backend.hcl`

1. Copy the template: `cp backend.hcl.example backend.hcl` (ignored by Git).
2. Update the fields:
   - `bucket`: name of the Terraform state bucket from PoC 1A.
   - `dynamodb_table`: DynamoDB lock table name.
   - `kms_key_id`: ARN or alias of the CMK protecting state.
   - `key`: `<stack>/terraform.tfstate` (unique per stack, e.g. `vpc/terraform.tfstate`).
   - `region`: usually `eu-west-3`.

Retrieve the values with AWS CLI if needed:

```bash
aws s3 ls | grep tfstate
aws dynamodb list-tables
aws kms list-aliases | grep tfstate
```

## Using the backend per stack

Example for the VPC stack:

```bash
cd infra/terraform/vpc
terraform init -backend-config=../backend.hcl
terraform plan
```

If you edit `backend.hcl`, re-run init with `-reconfigure`:

```bash
terraform init -reconfigure -backend-config=../backend.hcl
```

## Key naming convention

Keep one state key per stack to avoid collisions:

- `vpc/terraform.tfstate`
- `ecr/terraform.tfstate`
- `eks/terraform.tfstate`
- `rds/terraform.tfstate`
- `redis/terraform.tfstate`

## Safety notes

- Never commit the real `backend.hcl`; only the example lives in Git.
- Authenticate with short-lived AWS SSO creds (see `infra/bootstrap-state/README.md`).
- Separate keys per stack keeps apply/destroy blast-radius isolated.

## Troubleshooting

- **`InvalidClientTokenId` / expired token**: run `aws sso login --profile eks-pro-platform`.
- **`AccessControlListNotSupported` on logs bucket**: ensure the PoC 1A patch (BucketOwnerPreferred + ACL `log-delivery-write`) is applied.
- **State moved after changing `key`**: either revert to the previous key or migrate explicitly via `terraform state pull`/`push`.
