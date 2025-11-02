resource "kind_cluster" "default" {
  name           = "kind-local"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      kubeadm_config_patches = [<<-EOT
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
      EOT
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 8080
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 8443
        protocol       = "TCP"
      }
    }

    node { role = "worker" }
    node { role = "worker" }
  }
}

# Metrics Server (Kind-compatible args)
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"
  namespace  = "kube-system"

  values = [yamlencode({
    args = [
      "--kubelet-insecure-tls",
      "--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP"
    ]
  })]

  depends_on = [kind_cluster.default]
}

# Ingress NGINX (Kind-optimized config)
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.0"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [yamlencode({
    controller = {
      hostPort = {
        enabled = true
        ports   = { http = 80, https = 443 }
      }
      service = {
        type      = "NodePort"
        nodePorts = { http = 30080, https = 30443 }
      }
      watchIngressWithoutClass = true
    }
  })]

  depends_on = [kind_cluster.default]
}
