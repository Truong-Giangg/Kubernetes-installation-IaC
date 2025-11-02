# Minimal Kind Cluster

Structure:
```
modules/
  cluster/   # Kind cluster (1 CP + 2 workers)
  addons/    # Generic Helm addons (metrics-server, ingress-nginx)
environments/
  local/     # Wires modules together and providers inherit kubeconfig
```

This project deploys a **local Kubernetes cluster** using Kind and installs addons via Helm:

- **Metrics Server** (Kind-friendly args)
- **Ingress NGINX** (hostPorts + NodePorts, accessible via http://localhost:8080)

## Requirements

- Docker
- Terraform >= 1.6
- kubectl, helm, and kind installed locally

## Usage

```bash
cd environments/local
terraform init
terraform apply -auto-approve

# verify
kubectl --kubeconfig ../../modules/cluster/kubeconfig get nodes
kubectl --kubeconfig ../../modules/cluster/kubeconfig -n ingress-nginx get pods
kubectl --kubeconfig ../../modules/cluster/kubeconfig -n kube-system get pods
```