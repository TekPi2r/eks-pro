## PoC 1 — Remote State & CI Terraform (1A / 1B / 1C)

### 🧱 1A — Bootstrap du state (une fois par compte/env)

- Créer côté AWS :
  - S3 (versioning ON, block public, chiffrement KMS),
  - DynamoDB (PITR ON) pour le lock,
  - CMK KMS (rotation ON).
- Preuves : captures console (S3 versioning, DDB PITR, KMS key).

### 🔗 1B — Lier le backend au projet

- Commit `infra/terraform/backend.hcl` (pas de secrets) :

```hcl
  bucket         = "eks-pro-dev-tfstate"
  key            = "infra.tfstate"        # un seul root => une seule key
  region         = "eu-west-3"
  use_lockfile   = true   # NEW: native S3 locking (replaces dynamodb_table)
  encrypt        = true
  kms_key_id     = "arn:aws:kms:eu-west-3:<ACCOUNT_ID>:key/<CMK_ID>"
```

- Initialiser depuis le root :

```bash
  cd infra/terraform
  terraform init -backend-config=backend.hcl
```

- Preuve : `terraform init` OK.

### 🔐 1C — OIDC GitHub + rôle Terraform (plan-only) + CI

- Infra as Code (`infra/terraform/iam-oidc` + `modules/gh_oidc_plan`) :
  - Identity Provider GitHub OIDC (`token.actions.githubusercontent.com`),
  - Rôle **plan** (permissions limitées au state S3/DDB/KMS, trust scoping repo),
  - Outputs : `gha_tf_plan_role_arn`.
- Apply local (SSO) :

```bash
  aws sso login --profile eks-pro
  cd infra/terraform
  terraform apply -auto-approve
```

- Secret GitHub :
  - `AWS_ROLE_TF_PLAN_DEV` = valeur de `gha_tf_plan_role_arn`.
- CI (PR) : workflow `terraform-plan` ⇒ OIDC assume-role ⇒ `init/fmt/validate/plan`.

### 📦 Proof Pack (PoC 1)

- Run GitHub Actions **vert** `terraform-plan` (assume-role OK).
- Console IAM : rôle `…-gha-tf-plan` (Trust policy + Policy S3/DDB/KMS).

### 💡 Routine (dev courant)

- Plan CI (PR) : lecture seule (pas de lock).
- Apply local (SSO) : écrit le state (lock DDB).
- Plus tard, si Apply CI : créer un rôle `…-gha-tf-apply` + workflow `terraform-apply.yml` (protégé).

### ❓FAQ

- Un seul tfstate ? Oui (choix ROI). Remote state chiffré/locké + OIDC → assez “prod-like” pour ce PoC.
- `backend.hcl` contient des secrets ? Non. Il localise le state (OK pour commit).
- Conflits de state ? Le lock DynamoDB protège les apply. Les plans ne lockent pas.

### 🚀 Suite (PoC 2 → 8)

- **PoC 2 — Network & Images** : VPC (3 AZ, subnets pub/priv, NAT GW) + ECR (scan on push, lifecycle).
- **PoC 3 — EKS Cluster** : EKS + NodeGroup, IRSA, `aws-auth` RBAC CI.
- **PoC 4 — App** : Helm chart API (probes, HPA, PDB, anti-affinity) + Ingress ALB.
- **PoC 5 — Stateful** : RDS Postgres, Redis (StatefulSet + PVC EBS gp3), SecretsMgr via IRSA.
- **PoC 6 — DevSecOps gates** : fmt/lint → gitleaks → tfsec/Checkov → trivy → syft+cosign → OPA/Conftest.
- **PoC 7 — Observability & SRE** : Prometheus/Loki/Grafana (p95, CPU/mem, Redis/DB), budgets & cost tags, k6.
- **PoC 8 — Delivery & Pitch** : README final, captures, “Code→Prod on AWS”, liens PR clés.
