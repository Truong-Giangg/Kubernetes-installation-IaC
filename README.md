# Minimal Kind Cluster

This project deploys a **local Kubernetes cluster** using Kind and installs two core addons via Helm:

- **Metrics Server** (Kind-friendly args)
- **Ingress NGINX** (hostPorts + NodePorts, accessible via http://localhost:8080)

## Requirements

- Docker (running)
- Terraform >= 1.6
- kubectl, helm, and kind installed locally

## Usage

```bash
terraform init
terraform apply -auto-approve

# Check cluster and addons
kubectl get nodes
kubectl -n ingress-nginx get pods
kubectl -n kube-system get pods
```

Then access ingress via: **http://localhost:8080**
