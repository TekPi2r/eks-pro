# 📓 EKS Pro — Dev Journal

> One file, many entries. Keep it short, useful, and link to PRs/CI.

---

## 2025-11-05 — main — (commit: fef42eb)

### What I did

- Bootstrap repo: pre-commit + linters (gitleaks, markdownlint, yamllint, prettier, tflint, trivy).
- Added base configs: `.editorconfig`, `.gitattributes`, `.gitignore`, `LICENSE`, `README`.
- Scaffolds created: `infra/terraform/`, `app/`, `k8s/`, `ops/k6/`, `scripts/`.
- Added CODEOWNERS + PR template + tflint config.

### Why (impact / ROI / SRE)

- Standardized quality gates from day 0 (hire-ready hygiene).
- Fast feedback via hooks; reduces review time and defects.
- Prépare l’intégration SRE/DevSecOps (scans et docs SRE à venir).

### Evidence (links)

- Branch: `main`
- Commit: `fef42eb`
- PR: _(n/a — first push)_
- CI: _(à venir quand GitHub Actions seront ajoutées)_

### Next

- Branch `docs/sre-foundations` → ajouter SRE scaffolds (`docs/sre/*`).
- Planifier `PoC 1A.1` (backend Terraform) ou pause dev si SRE d’abord.

### SRE notes

- SLO touched? ☑ no (scaffolds à faire)
- Runbook / postmortem updated? ☐/☐

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
