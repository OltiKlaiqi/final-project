# Runbook — Demo API + Worker

Purpose: quick playbook for on-call engineers to diagnose and mitigate alerts for the `demo` service (demo-api and demo-worker).

Owner: `team-demo@example.com` (replace with real on-call contact)

## Access

- Grafana: `http://localhost:3000` (port-forward `svc/kube-prometheus-grafana` in the `monitoring` namespace)
- Prometheus: `http://localhost:9090` (port-forward `svc/kube-prometheus-kube-prome-prometheus` in `monitoring`)
- Kubernetes: use `kubectl -n demo` for app objects and `kubectl -n monitoring` for monitoring objects.

## Common kubectl commands

```
kubectl -n demo get pods
kubectl -n demo get deploy demo-api -o wide
kubectl -n demo describe pod <pod>
kubectl -n demo logs deployment/demo-api
kubectl -n monitoring get prometheusrules
kubectl -n demo get hpa
```

---

## Alert Playbooks

### HighCPUUsage (Prometheus alert `HighCPUUsage`)

1. Confirm alert in Prometheus / Alertmanager and note `startsAt` and annotations.
2. Check current CPU usage in Prometheus:

```
sum(rate(container_cpu_usage_seconds_total{namespace="demo",pod=~"demo-api.*"}[1m])) by (pod)
```

3. Identify affected pods:

```
kubectl -n demo get pods -o wide
kubectl -n demo top pods     # if metrics-server is available
kubectl -n demo describe pod <pod>
kubectl -n demo logs <pod>
```

4. Mitigation options (ordered):

- Increase HPA minReplicas temporarily: `kubectl -n demo patch hpa demo-api-hpa -p '{"spec":{"minReplicas":2}}'` or scale the deployment: `kubectl -n demo scale deploy/demo-api --replicas=3`
- If CPU is sustained due to legitimate load, consider increasing resource `requests/limits` in the Deployment and redeploy.
- Restart a problematic pod: `kubectl -n demo delete pod <pod>` (controller will recreate it).
- If a recent deployment caused the spike, roll back: `kubectl -n demo rollout undo deployment/demo-api`.

5. Validate: confirm CPU drops and alert resolves. Add notes to ticket.

### LowReplicas (Prometheus alert `LowReplicas`)

1. Confirm alert and affected object: `kubectl -n demo get deploy demo-api -o yaml`
2. Inspect deployment status and events: `kubectl -n demo describe deploy/demo-api`
3. If pods are not being scheduled, check node conditions and events.
4. Mitigation:

- Scale deployment back to desired replicas: `kubectl -n demo scale deployment/demo-api --replicas=1`
- If pods crash (CrashLoopBackOff), inspect logs and fix the crash (config/secrets/image).

---

## Diagnostics — Prometheus queries (examples)

- API success rate (5m):

```
sum(rate(http_requests_total{job="demo-api",code=~"2.."}[5m]))
/
sum(rate(http_requests_total{job="demo-api"}[5m]))
```

- API error rate (5m):

```
sum(rate(http_requests_total{job="demo-api",code!~"2.."}[5m]))
/
sum(rate(http_requests_total{job="demo-api"}[5m]))
```

- API p95 latency (5m) — if you expose a histogram `http_request_duration_seconds_bucket`:

```
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="demo-api"}[5m])) by (le))
```

- CPU per pod:

```
sum(rate(container_cpu_usage_seconds_total{namespace="demo",pod=~"demo-api.*"}[1m])) by (pod)
```

---

## Testing & Load

- Quick load (simple curl loop):

```
for i in {1..200}; do curl -s http://localhost:8080/hello > /dev/null & done
```

- Using `hey` (recommended) to simulate concurrency:

```
hey -z 60s -c 50 http://localhost:8080/hello
```

- Verify HPA scaling:

```
kubectl -n demo get hpa demo-api-hpa --watch
kubectl -n demo get pods -l app=demo-api
```

---

## Alert routing & contacts

- Severity `warning`: notify `#demo-warnings` (or equivalent)
- Severity `critical`: page on-call and notify `#demo-critical`

Replace these placeholders with your real alerting endpoints and on-call contacts.

## Silencing alerts

- Use Alertmanager UI to silence alerts briefly when remediation is in progress. Document reason and owner in the incident ticket.

## Post-incident

- Create an incident ticket with timeline, root cause, and actions taken.
- Add follow-up tasks: configuration fixes, resource changes, or testing.

## Notes

- Keep this runbook updated with real contacts and new automation scripts (load generators, remediation scripts).
