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
| 2   | Network & Images | VPC (3 AZ) + ECR repos                                      | 🔜 Next |
| …   |                  | EKS → App → RDS/Redis → DevSecOps → SRE → Delivery          |         |

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
