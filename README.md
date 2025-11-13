# 🏔️ EKS Pro

AWS EKS production-ready blueprint — **Node.js API (stateless) + Redis (StatefulSet) + RDS Postgres**.
Infrastructure as Code with **Terraform**, CI/CD via **GitHub Actions (OIDC)**, and **DevSecOps gates** (Gitleaks, tfsec/Checkov, Trivy, Syft/Cosign).
Observability: **Prometheus + Grafana + Loki**, with SRE baselines (SLO/SLI, runbooks, error budget).

---

## ⚙️ What’s inside

- **Infra / Terraform**
  - Modularized: `iam_oidc`, `vpc`, `ecr`, `eks`, `rds`, `redis`.
  - One remote state (S3 + DynamoDB + KMS) per environment.
- **CI/CD**
  - `terraform-plan.yml`: plan-only workflow via **GitHub OIDC** (no secrets).
  - Apply done locally via **AWS SSO** short-lived credentials.
- **App**
  - Node.js API with Helm chart (Ingress ALB, HPA, Probes, PDB, Affinity).
- **Security**
  - Pre-commit hooks: lint + secrets + IaC + Docker scans.
  - DevSecOps stage (PoC 6) → tfsec, Checkov, Trivy, Syft/Cosign.
- **SRE / Observability**
  - Templates: SLO/SLI, runbook, postmortem, game day, alert policy.
  - Future dashboards p95 latency / CPU / Redis / DB metrics.

---

## 🚀 Current status

| PoC | Stage            | Description                                                 | Status  |
| :-- | :--------------- | :---------------------------------------------------------- | :-----: |
| 1A  | Bootstrap state  | S3 + KMS + DynamoDB (PITR) via SSO profile                  | ✅ Done |
| 1B  | Backend wiring   | `backend.hcl` + docs + example                              | ✅ Done |
| 1C  | OIDC + Plan CI   | IAM OIDC Provider + Role `gha-tf-plan` + plan-only workflow | ✅ Done |
| 2   | Network & Images | VPC (3 AZ, NAT, Flow Logs) + ECR (CMK)                      | ✅ Done |
| 3   | EKS Cluster      | EKS cluster + Node Group + aws-auth                         | 🔜 Next |

See full progression → [`docs/journal.md`](./docs/journal.md)

---

## 🧠 Quick start (Dev setup)

```bash
# 1️⃣ Install pre-commit
pipx install pre-commit || pip install pre-commit
pre-commit install --install-hooks

# 2️⃣ Bootstrap infra (local)
cd infra/terraform
terraform init -backend-config=backend.hcl
terraform plan
```

---

### Cloud ROI focus: production-grade project demonstrating AWS EKS + DevSecOps practices for a Cloud Engineer /DevOps role

---

### ✔️ PoC 1 — Terraform Backend & GitHub OIDC

This stage establishes the secure Terraform foundation for the whole project.

#### 🔹 Remote Backend (1A)

- Encrypted **S3 bucket** for Terraform state
- **DynamoDB** state locking
- **KMS CMK** for state encryption
- Bootstrapped using AWS SSO short-lived credentials

#### 🔹 Backend Wiring (1B)

- Added `backend.hcl.example` + project-wide backend configuration
- Ensures all future stacks share the same secure remote state

#### 🔹 GitHub Actions OIDC (1C)

- Created **GitHub OIDC provider**
- IAM role `eks-pro-dev-gha-tf-plan` for Terraform `plan`
- Permissions: S3/DDB/KMS state access only (least privilege)
- CI pipeline now runs Terraform plan with **zero secrets**

#### 📁 Proof Pack - PoC 1

All screenshots available in: `docs/proofs/poc-01/`.

---

### ✔️ PoC 2 — Network & Images

This stage delivers the production-grade network foundation for the future EKS cluster, plus secure image storage.

#### 🔹 Network (VPC)

- **VPC**: `10.0.0.0/16`
- **Subnets**: 3 public + 3 private across **eu-west-3a / 3b / 3c**
- **Routing**:
  - Public → Internet Gateway
  - Private → 1 × NAT Gateway (cost-optimized)
- **Flow Logs** → CloudWatch Logs (30-day retention)
  - Using AWS-managed KMS key (CMK hardening planned for later PoC)

#### 🔹 Container Images (ECR)

- **ECR repository**: `eks-pro-dev-app`
- **Encryption**: Customer-Managed KMS Key (CMK)
- **Scan on push**: enabled
- **Lifecycle policy**: cleanup of old/untagged images

#### 📁 Proof Pack - PoC 2

All screenshots available in: `docs/proofs/poc-02/`.
