#!/bin/bash

set -e

INSTALL_DIR="/usr/local/bin"

# Ensure dependencies
command -v curl >/dev/null 2>&1 || { echo >&2 "❌ curl is required but not installed. Aborting."; exit 1; }
command -v tar >/dev/null 2>&1 || { echo >&2 "❌ tar is required but not installed. Aborting."; exit 1; }

echo "📦 Installing tools to $INSTALL_DIR"

### Install kubectl ###
install_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    echo "✅ kubectl already installed: $(kubectl version --client | grep 'Client Version' | awk -F ': ' '{print $2}' | tr -d '\"')"
  else
    echo "📥 Installing kubectl..."
    KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl "$INSTALL_DIR/kubectl"
    echo "✅ kubectl installed: $($INSTALL_DIR/kubectl version --client --short)"
  fi
}

### Install kind ###
install_kind() {
  if command -v kind >/dev/null 2>&1; then
    echo "✅ kind already installed: $(kind version)"
  else
    echo "📥 Installing kind..."
    KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name":' | cut -d '"' -f4)
    curl -Lo kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
    chmod +x kind
    sudo mv kind "$INSTALL_DIR/kind"
    echo "✅ kind installed: $($INSTALL_DIR/kind version)"
  fi
}

### Install helm ###
install_helm() {
  if command -v helm >/dev/null 2>&1; then
    echo "✅ helm already installed: $(helm version --short)"
  else
    echo "📥 Installing helm..."
    HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name":' | cut -d '"' -f4)
    curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
    tar -zxvf "helm-${HELM_VERSION}-linux-amd64.tar.gz"
    chmod +x linux-amd64/helm
    sudo mv linux-amd64/helm "$INSTALL_DIR/helm"
    rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64
    echo "✅ helm installed: $($INSTALL_DIR/helm version --short)"
  fi
}

# Run install functions
install_kubectl
install_kind
install_helm

echo -e "\n🎉 All tools are installed and ready."
