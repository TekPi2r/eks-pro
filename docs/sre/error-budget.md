# Error Budget Policy

Short purpose: translate SLOs into a consumable budget to guide trade-offs between velocity and reliability.
When to update: monthly review or whenever SLO targets change.

Reference SLO (prod-ready)

- Uptime target: 99.9% => monthly budget ≈ 43 minutes of downtime.

Dev mode (service-hours)

- Budget calculation applies only during Mon–Fri 09:00–18:00 (Europe/Paris).
- Out-of-hours planned stops are excluded.

Policy

- If budget consumption >50% by the 20th of the month: freeze feature work and focus on reliability.
- Track consumption via synthetic checks and ALB metrics once available.
