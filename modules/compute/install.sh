#!/bin/bash
set -euo pipefail

log() { echo "[install] $*"; }

log "Detecting OS and installing Docker..."
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  
  # Wait for apt locks to be released (unattended-upgrades often locks it on boot)
  while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
    log "Waiting for other software managers to finish..."
    sleep 5
  done
  
  apt-get update -y
  apt-get install -y docker.io curl ca-certificates
  systemctl enable --now docker
  if id ubuntu >/dev/null 2>&1; then
    usermod -aG docker ubuntu || true
  fi
elif command -v yum >/dev/null 2>&1; then
  yum update -y
  yum install -y docker curl ca-certificates
  systemctl enable --now docker
  if id ec2-user >/dev/null 2>&1; then
    usermod -aG docker ec2-user || true
  fi
else
  log "Unsupported OS (no apt-get/yum found)."
  exit 1
fi

log "Installing kubectl..."
KVER="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$${KVER}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

log "Installing kind..."
curl -L -o /usr/local/bin/kind "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64"
chmod +x /usr/local/bin/kind

log "Writing kind cluster config..."
cat <<'EOF' > /root/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: ${nodeport_port}
    hostPort: ${nodeport_port}
    protocol: TCP
- role: worker
EOF

log "Creating kind cluster..."
kind create cluster --config /root/kind-config.yaml

