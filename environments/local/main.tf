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
    ingress_nginx = {
      chart     = "ingress-nginx"
      repo      = "https://kubernetes.github.io/ingress-nginx"
      version   = "4.11.0"
      namespace = "ingress-nginx"
      values    = {
        controller = {
          hostPort = { enabled = true, ports = { http = 80, https = 443 } }
          service  = { type = "NodePort", nodePorts = { http = 30080, https = 30443 } }
          watchIngressWithoutClass = true
        }
      }
    }
  }
}
