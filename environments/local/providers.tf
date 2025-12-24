terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kind       = { source = "tehcyx/kind",          version = "~> 0.5" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.33" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.13" }
    local      = { source = "hashicorp/local",      version = "~> 2.5" }
    time = { source = "hashicorp/time", version = "~> 0.11" }
  }
}

provider "kubernetes" {
  config_path = module.cluster.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = module.cluster.kubeconfig_path
  }
}
