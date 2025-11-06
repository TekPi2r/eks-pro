# Runbook — API

Short purpose: step-by-step to reduce MTTR during incidents. Anyone can execute it under stress.
When to update: after each incident or game day.

Symptoms

- /healthz failing, 5xx spikes, p95 latency above target.

Quick checks

- kubectl get pods -n `<ns>`, describe, logs
- Check recent deploys, HPA status, events
- Verify Redis and Postgres connectivity

Actions

- Roll back Helm release to N-1
- Redeploy if config error identified
- Escalation: owner on-call (email/slack placeholder)

Post actions

- Open an incident record and fill the postmortem template
- Create follow-up tasks with owners and due dates
