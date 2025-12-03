terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.15.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
  }
}

# Kubernetes provider pointing to local kind cluster
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Helm provider for Prometheus/Grafana installation
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}