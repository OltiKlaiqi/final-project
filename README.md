# final-project
Infra + K8s + Observability demo project


Runbook — Demo API + Worker Project
1️⃣ Prerequisites

Docker installed

Kind (Kubernetes in Docker) or a local Kubernetes cluster

kubectl configured to point to the cluster

Helm installed

Terraform installed

2️⃣ One-command Setup

Run the following from the root of your repo:

make init apply deploy


This will:

Initialize Terraform

Deploy infrastructure (if any Terraform modules)

Deploy Kubernetes objects:

demo-api Deployment + Service

demo-worker Deployment

HPA for demo-api

ServiceMonitor for Prometheus

PrometheusRule alerts

3️⃣ Port-forwarding

Open two separate terminals:

Grafana
kubectl -n monitoring port-forward svc/kube-prometheus-grafana 3000:80


Open browser: http://localhost:3000

Login: admin/admin (or configured password)

Prometheus
kubectl -n monitoring port-forward svc/kube-prometheus-kube-prome-prometheus 9090:9090


Open browser: http://localhost:9090

Keep both terminals open while testing dashboards and alerts.

4️⃣ Test API & Metrics
curl http://localhost:8080/hello
curl http://localhost:8080/metrics


The first command returns a “Hello” response.

The second returns Prometheus metrics from your API.

Optional: generate load to see HPA scaling:

for i in {1..50}; do curl http://localhost:8080/hello & done
kubectl get hpa -n demo --watch

5️⃣ Check Prometheus Targets

Open Prometheus → Status → Targets

Ensure demo-api and demo-worker targets show UP.

6️⃣ Grafana Dashboards

Import /dashboards/demo-dashboard.json

Panels included:

API Requests Per Second (RPS)

Worker Jobs Processed

CPU Usage (demo-api)

Memory Usage (demo-api)

HPA Replicas

7️⃣ Alerts

PrometheusRule /alerts/demo-alerts.yaml contains:

High CPU Usage (>80%)

Low Replicas (<1)

Alerts can be viewed in Grafana → Alerting → Alerts

8️⃣ One-command Teardown
make destroy


Deletes all Kubernetes objects and Terraform-managed infrastructure.

✅ Notes

If API metrics don’t appear in Grafana:

Check Service labels: kubectl get svc demo-api -n demo --show-labels

Check Prometheus targets: http://localhost:9090/targets

CPU/Memory and HPA panels always work, even if custom API metrics are missing.
