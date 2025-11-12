# 📓 EKS Pro — Dev Journal

> One file, many entries. Keep it short, useful, and link to PRs/CI.

---

## 2025-11-05 — main

### What I did — bootstrap

- Bootstrap repo: pre-commit + linters (gitleaks, markdownlint, yamllint, prettier, tflint, trivy).
- Added base configs: `.editorconfig`, `.gitattributes`, `.gitignore`, `LICENSE`, `README`.
- Scaffolds created: `infra/terraform/`, `app/`, `k8s/`, `ops/k6/`, `scripts/`.
- Added CODEOWNERS + PR template + tflint config.

### Why (impact / ROI / SRE) — bootstrap

- Standardized quality gates from day 0 (hire-ready hygiene).
- Fast feedback via hooks; reduces review time and defects.
- Prépare l’intégration SRE/DevSecOps (scans et docs SRE à venir).

---

## 2025-11-06 — docs/sre-foundations

### What I did — docs/sre-foundations

- Added SRE foundations: SLO/SLI, error budget, runbook, postmortem template, game day, alert policies.

### Why (impact / ROI / SRE) — docs/sre-foundations

- Define reliability targets and incident workflow early; improves clarity for future CI/Observability and interviews.

---

## 2025-11-07 — feat/poc-01a-terraform-backend

### What I did — PoC 1A

- Enabled AWS IAM Identity Center; created user + permission set `PlatformBootstrap` (temp AdminAccess).
- Configured local SSO profile `eks-pro-platform`.
- `terraform apply` (S3 tfstate + logs, KMS CMK, DynamoDB lock w/ PITR) → OK.
- Tested `terraform destroy` then final `apply` → OK.

### Why (impact / ROI / SRE) — PoC 1A

- Short-lived creds (MFA) from day 1, no long-lived keys.
- Versioned, encrypted state + lock table → safer infra changes.
- Sets the stage for OIDC CI/CD (no secrets) next.

### Evidence — PoC 1A

- Profile: `eks-pro-platform` (SSO, eu-west-3)
- Account: `325107200902`
- Resources: S3 (`*-tfstate`, `*-tfstate-logs`), KMS CMK (rotation on), DDB lock (PITR on)

---

## 2025-11-07 — feat/poc-01b-backend-wiring

### What I did — PoC 1B

- Added `backend.hcl.example` + README to wire future stacks to remote state (S3/DDB/KMS).
- Gitignored local `backend.hcl`.

### Why (impact / ROI / SRE) — PoC 1B

- Consistent remote state across stacks, no secrets committed, faster onboarding.

---

## 2025-11-12 — feat/poc-01c-oidc-plan-ci

### What I did — PoC 1C

- Added Terraform module `iam_oidc` + submodule `gh_oidc_plan` (GitHub → AWS OIDC Provider + IAM Role).
- Created role **`eks-pro-dev-gha-tf-plan`** with minimal RW on remote state (S3/DDB/KMS) + IAM read for refresh.
- Configured **GitHub Actions workflow `terraform-plan.yml`** :
  - OIDC assume-role (no secrets)
  - Steps: init / fmt / validate / plan with concurrency + guards
- Local `terraform apply` (via AWS SSO) → state synced and CI plan verified.
- Plan CI ✅ green (Init → Fmt → Validate → Plan).

### Why (impact / ROI / SRE) — PoC 1C

- Secure, **no long-lived AWS keys** in pipelines (OIDC auth only).
- **Separation of duties:** Plan in CI, Apply local via SSO until infra stabilizes.
- Builds foundation for **future CI/CD App and DevSecOps gates** without rework.
- Demonstrates **production-ready IAM boundaries** for recruiter review / portfolio.

### Evidence — PoC 1C

- `gh-actions-plan.png` → All jobs green in CI.
- `iam-role-gha-tf-plan.png` → Trust policy + attached policy JSON.
- `terraform-apply-local.png` → Local apply success (output summary).
- (OIDC provider visible in AWS Console → `token.actions.githubusercontent.com`)

---

## YYYY-MM-DD — `<branch>` — Template

### What I did (template)

- …

### Why (impact / ROI / SRE) — template

- …

### Evidence (optionnal) — template

- …
