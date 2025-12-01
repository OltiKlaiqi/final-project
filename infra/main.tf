resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

# Example: a ConfigMap for app settings
resource "kubernetes_config_map" "demo_config" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  data = {
    APP_NAME = "demo-app"
    ENV      = "local"
  }
}