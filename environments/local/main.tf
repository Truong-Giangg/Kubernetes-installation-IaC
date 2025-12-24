module "cluster" {
  source = "../../modules/cluster"
  name   = var.cluster_name
}

module "addons" {
  source = "../../modules/addons"
  addons = {
    metrics_server = {
      chart     = "metrics-server"
      repo      = "https://kubernetes-sigs.github.io/metrics-server/"
      version   = "3.12.1"
      namespace = "kube-system"
      values    = {
        args = [
          "--kubelet-insecure-tls",
          "--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP"
        ]
      }
    }
    # ingress controller - 30080 (kind) <-> 8080 (host)
    ingress_nginx = {
      chart     = "ingress-nginx"
      repo      = "https://kubernetes.github.io/ingress-nginx"
      version   = "4.11.0"
      namespace = "ingress-nginx"
      values    = {
        controller = {
          hostPort = { enabled = false }
          service  = { type = "NodePort", nodePorts = { http = 30080, https = 30443 } }
          watchIngressWithoutClass = true
        }
      }
    }
  }
}

# Give ingress-nginx (and its admission webhook) time to become Ready
resource "time_sleep" "wait_for_ingress_webhook" {
  depends_on      = [module.addons]
  create_duration = "30s"
}

# Argo CD: ClusterIP + Ingress (or NodePort only)
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [yamlencode({
    dex = { enabled = false }
    configs = { params = { "server.insecure" = "true" } }
    server = {
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        hostname         = "argocd.meiot.live"
        annotations = {
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
        }
        hosts = [
          {
            host  = "argocd.meiot.live"
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
        tls = []
      }
      service = { type = "ClusterIP" }
    }
  })]

  depends_on = [time_sleep.wait_for_ingress_webhook]
}

