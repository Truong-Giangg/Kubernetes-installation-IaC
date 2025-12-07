terraform {
  required_providers {
    kind = { source = "tehcyx/kind", version = "~> 0.5" }
    local = { source = "hashicorp/local", version = "~> 2.5" }
  }
}

variable "name" {
  type    = string
  default = "kind-local"
}

variable "extra_port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = [
    { containerPort = 30080, hostPort = 80, protocol = "TCP" },
    { containerPort = 30443, hostPort = 443, protocol = "TCP" }
  ]
}

resource "kind_cluster" "this" {
  name           = var.name
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

      dynamic "extra_port_mappings" {
        for_each = var.extra_port_mappings
        content {
          container_port = extra_port_mappings.value.containerPort
          host_port      = extra_port_mappings.value.hostPort
          protocol       = extra_port_mappings.value.protocol
        }
      }
    }

    node { role = "worker" }
    node { role = "worker" }
  }
}

resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig"
  content  = kind_cluster.this.kubeconfig
}

output "kubeconfig_path" {
  value       = local_file.kubeconfig.filename
  description = "Kubeconfig path for this cluster"
}
