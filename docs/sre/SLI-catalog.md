# SLI Catalog

Short purpose: define exactly how we measure “good” (formulas, sources, scope). Avoid ambiguity and enable reproducible dashboards/alerts.
When to update: when new signals appear (ALB logs, app metrics, k6), or scope changes.

Availability

- Definition: (2xx+3xx) / total requests.
- Source: ALB access logs or synthetic endpoint checks.
- Scope: service-hours in dev; 24/7 in prod.

Latency

- Definition: p50, p95, p99 on route `/`.
- Source: app metrics, ALB, synthetic (k6).
- Scope: service-hours in dev; 24/7 in prod.

Errors

- Definition: 5xx rate over total requests.
- Source: ALB logs, app logs/metrics.
- Scope: service-hours in dev; 24/7 in prod.
