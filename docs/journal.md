# 📓 EKS Pro — Dev Journal

> One file, many entries. Keep it short, useful, and link to PRs/CI.

---

## 2025-11-05 — main — (commit: fef42eb)

### What I did — bootstrap

- Bootstrap repo: pre-commit + linters (gitleaks, markdownlint, yamllint, prettier, tflint, trivy).
- Added base configs: `.editorconfig`, `.gitattributes`, `.gitignore`, `LICENSE`, `README`.
- Scaffolds created: `infra/terraform/`, `app/`, `k8s/`, `ops/k6/`, `scripts/`.
- Added CODEOWNERS + PR template + tflint config.

### Why (impact / ROI / SRE) — bootstrap

- Standardized quality gates from day 0 (hire-ready hygiene).
- Fast feedback via hooks; reduces review time and defects.
- Prépare l’intégration SRE/DevSecOps (scans et docs SRE à venir).

### Evidence (links) — bootstrap

- Branch: `main`
- Commit: `fef42eb`
- PR: _(n/a — first push)_
- CI: _(à venir quand GitHub Actions seront ajoutées)_

### Next — bootstrap

- Branch `docs/sre-foundations` → ajouter SRE scaffolds (`docs/sre/*`).
- Planifier `PoC 1A.1` (backend Terraform) ou pause dev si SRE d’abord.

### SRE notes — bootstrap

- SLO touched? ☑ no (scaffolds à faire)
- Runbook / postmortem updated? ☐/☐

---

## 2025-11-06 — docs/sre-foundations — (commit: <short-sha>)

### What I did — docs/sre-foundations

- Added SRE foundations: SLO/SLI, error budget, runbook, postmortem template, game day, alert policies.

### Why (impact / ROI / SRE) — docs/sre-foundations

- Define reliability targets and incident workflow early; improves clarity for future CI/Observability and interviews.

### Evidence (links) — docs/sre-foundations

- PR: [PR link](https://github.com/YOUR_GITHUB_USER/eks-pro/pull/<number>)
- CI: n/a (docs-only PR)

### Next — docs/sre-foundations

- Decide Terraform backend (S3+DynamoDB vs Terraform Cloud) and start PoC 1 when resuming dev.

### SRE notes — docs/sre-foundations

- SLO touched? yes
- Runbook/postmortem updated? scaffolded

---

## YYYY-MM-DD — `<branch>` — (commit: `<short-sha>`) — Template

### What I did (template)

- …

### Why (impact / ROI / SRE) — template

- …

### Evidence (links) — template

- PR: [PR link](https://github.com/YOUR_GITHUB_USER/eks-pro/pull/…)
- CI: [CI run](https://github.com/YOUR_GITHUB_USER/eks-pro/actions/runs/…)

### Next — template

- …

### SRE notes — template

- SLO touched? ☐ yes / ☐ no
- Runbook / postmortem updated? ☐/☐
