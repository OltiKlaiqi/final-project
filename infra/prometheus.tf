resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  # Use list of maps instead of block
  set = [
    {
      name  = "grafana.adminPassword"
      value = "admin"
    },
    {
      name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
      value = "false"
    }
  ]
}
