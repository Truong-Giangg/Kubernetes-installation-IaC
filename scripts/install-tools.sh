#!/usr/bin/env bash
set -e

# Versions
TF_VERSION=1.6.6
KIND_VERSION=0.23.0
KUBECTL_VERSION=1.30.0
HELM_VERSION=3.15.3
DOCKER_COMPOSE_VERSION=2.27.0

# Ensure required tools
apt-get update -y
apt-get install -y unzip ca-certificates curl gnupg lsb-release make

# Terraform
curl -LO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip -o terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin
rm -f terraform_${TF_VERSION}_linux_amd64.zip

# Kind
curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
chmod +x /usr/local/bin/kind

# kubectl
curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# Helm
curl -Lo helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
tar -zxvf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm.tar.gz

# Docker (Engine + CLI + Compose plugin)
if ! command -v docker &> /dev/null; then
  echo "🚀 Installing Docker..."

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Add current user to docker group (so docker commands don't need sudo)
  USER_TO_ADD=${SUDO_USER:-$USER}
  usermod -aG docker "$USER_TO_ADD"

  echo "✅ Docker installed successfully."
  echo "⚠️ Please log out and back in (or run 'newgrp docker') for group changes to take effect."
else
  echo "ℹ️ Docker already installed, skipping..."
fi

echo "✅ All tools installed successfully."