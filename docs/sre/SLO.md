# SLO — EKS Pro

Short purpose: define reliability targets from the user’s point of view. Distinguish prod 24/7 vs dev service-hours so metrics reflect intent.
When to update: at first deploy (PoC 3) and when observability goes live (PoC 7).

## Profiles and scope

- Prod-ready (reference): 24/7, public-facing.
- Dev (current): service-hours only. The app is intentionally off outside dev sessions.
  - Service Level Calendar (Europe/Paris): Mon–Fri 09:00–18:00.
  - SLI and error budget apply only during service-hours.
  - Planned stops outside service-hours are excluded from downtime.

## SLOs (prod-ready, reference)

- Uptime (rolling 30d): 99.9% (~43 min/month).
- Latency p95 on route `/`: <300 ms during business hours, <500 ms outside.
- Error rate 5xx: <0.1%.

## SLOs (dev, service-hours)

- Uptime during service-hours: best effort (no strict target yet).
- Latency p95 `/` (service-hours): <500 ms.
- Error rate 5xx (service-hours): start <1%, then tighten to <0.5%, then <0.1%.

## SLI sources

- Availability and errors: ALB access logs or synthetic checks.
- Latency: app/ALB metrics and synthetic (k6).
- Scope: SLIs filtered by the Service Level Calendar (dev).

## Alerting (later with observability)

- Dev: probes and alerts only during service-hours.
- Prod: 24/7 alerts and burn-rate policies aligned to 99.9%.
