# Game Day Plan (lite)

Short purpose: rehearse failure safely to validate SLOs, runbooks, and alerting.
When to update: before each exercise; record results afterwards.

Scenario 1: kill one API pod

- Expected: service remains healthy (PDB/HPA), no sustained alert.
- Procedure: follow runbook, validate rollback path.

Scenario 2: stop one Redis replica

- Expected: app remains functional with retries/cache logic.
- Procedure: follow runbook, verify alerting and recovery.

Evidence

- Capture logs, metrics, and outcomes.
- File a postmortem if objectives were not met.
