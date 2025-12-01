terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.15.0"
    }
  }
}

# Kubernetes provider pointing to local kind cluster
provider "kubernetes" {
  config_path = "~/.kube/config"
}