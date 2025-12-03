# SLOs — Demo API

Service: `demo-api` (HTTP service exposing `/hello` and `/metrics`)

Owner: `team-demo@example.com` (replace with production on-call)

Measurement window: rolling 30 days (30d)

SLIs (what we measure)
- Availability: fraction of successful requests (HTTP 2xx) vs total requests.
- Latency: p95 request latency (using histogram `http_request_duration_seconds_bucket` if available).
- Error rate: fraction of non-2xx responses (5m and 30d views).

SLO targets (examples)
- Availability: 99.9% (monthly / 30d)
- Latency: p95 < 300ms (5m rolling)
- Error rate: < 0.1% (5m rolling)

Error budget
- For Availability 99.9% over 30d, error budget = 0.1% of requests in that window.
- Track burn rate and alert when a large fraction of the error budget is consumed.

Prometheus queries (examples)

- Availability (30d):
```
sum(rate(http_requests_total{job="demo-api",code=~"2.."}[30d]))
/
sum(rate(http_requests_total{job="demo-api"}[30d]))
```

- Error rate (5m):
```
sum(rate(http_requests_total{job="demo-api",code!~"2.."}[5m]))
/
sum(rate(http_requests_total{job="demo-api"}[5m]))
```

- p95 latency (5m):
```
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="demo-api"}[5m])) by (le))
```

Suggested alerting tied to SLOs
- Error budget burn rate (example): alert when error budget consumed > 50% in 7 days (adjust to fit your policy).
- High p95 latency (5m) → page on-call if p95 > 800ms for 5m.
- Availability drops below SLO (30d) → critical paging.

How to compute burn rate (simple approach)
- Let S = SLO target (e.g., 0.999). Error budget fraction = (1 - S).
- Over your evaluation window (e.g., 30d), compute observed error fraction E.
- Burn = E / (1 - S). If Burn > 1 → error budget exhausted.

Operational notes
- Record SLO violations in the incident ticket and trigger post-incident reviews when error budget is exhausted.
- Revisit SLOs quarterly; adjust thresholds after changing traffic patterns or architecture.


