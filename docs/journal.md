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

## YYYY-MM-DD — `<branch>` — Template

### What I did (template)

- …

### Why (impact / ROI / SRE) — template

- …
