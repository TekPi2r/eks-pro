# Terraform Bootstrap — Remote State (S3 + DynamoDB)

## Purpose

Provision a versioned, encrypted, private S3 bucket and a DynamoDB table for Terraform state locking.
Optionally produce an IAM policy with minimal RW permissions on that specific state (least privilege).

## Who runs this

A Cloud/Platform Engineer (or you) assuming a role with the **permissions listed below** on the target AWS account.

### Required permissions (least-privilege for this bootstrap)

S3 (bucket setup):

- s3:CreateBucket, s3:PutBucketVersioning, s3:PutBucketOwnershipControls,
  s3:PutBucketPublicAccessBlock, s3:PutEncryptionConfiguration,
  s3:PutLifecycleConfiguration, s3:GetBucketLocation, s3:ListBucket

DynamoDB (state lock table):

- dynamodb:CreateTable, dynamodb:DescribeTable, dynamodb:TagResource

IAM (optional, only if you create the tfstate RW policy here):

- iam:CreatePolicy, iam:TagPolicy, iam:GetPolicy, iam:ListPolicies

Notes:

- Some “create” actions must be allowed on `*` (resource doesn’t exist yet).
- If `iam:CreatePolicy` isn’t allowed in your org, skip creating the policy here and attach it later.

## Auth (AWS SSO)

Use a local SSO profile (short-lived creds). Example `~/.aws/config`:

```ini
[sso-session eks-pro]
sso_start_url = https://d-80677b88eb.awsapps.com/start
sso_region = eu-west-3
sso_registration_scopes = sso:account:access

[profile eks-pro-platform]
sso_session    = eks-pro
sso_account_id = 325107200902
sso_role_name  = PlatformBootstrap
region         = eu-west-3
output         = json
```

### Login & verify

```bash
aws sso login --profile eks-pro-platform
aws sts get-caller-identity --profile eks-pro-platform
```

## When

Once per environment (e.g., dev now; staging/prod later).
Rarely changed; **do not destroy**.

## How (dev example)

```bash
cd infra/bootstrap-state
AWS_PROFILE=eks-pro-platform terraform init
AWS_PROFILE=eks-pro-platform terraform apply \
  -var 'project=eks-pro' \
  -var 'env=dev' \
  -var 'aws_region=eu-west-3'
  # optionally:
  # -var 'bucket_name=<globally-unique-bucket>'
```

## Outputs to capture

- `s3_bucket_name`, `s3_bucket_arn`
- `dynamodb_table_name`, `dynamodb_table_arn`
- `kms_key_arn`

## Cost note

~€1–2/month (1 KMS key + minimal S3/DynamoDB usage for state/lock).
