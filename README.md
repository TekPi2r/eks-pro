# EKS Pro

AWS EKS production-ready blueprint — **Node.js API (stateless) + Redis (StatefulSet) + RDS Postgres**.
Infrastructure as Code with **Terraform**, CI/CD via **GitHub Actions (OIDC)**, and **DevSecOps** (Gitleaks, tfsec/Checkov, Trivy, Syft/Cosign). Observability: **Prometheus, Grafana, Loki**.

## What’s inside

- Infra: Terraform modules (VPC, ECR, EKS, RDS, Redis).
- App: Node.js API.
- Security: pre-commit hooks (format, lint, secrets, IaC & Docker checks).
- Tests: unit/integration + k6 (ops/).

## Quick start

```bash
# Install pre-commit
pipx install pre-commit || pip install pre-commit
pre-commit install --install-hooks
```
