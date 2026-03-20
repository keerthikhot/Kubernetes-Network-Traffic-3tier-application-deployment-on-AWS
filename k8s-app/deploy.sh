#!/bin/bash
set -e

echo "Deploying to Kubernetes Kind Cluster..."

echo "1. Applying Namespace..."
kubectl apply -f namespace.yaml
sleep 2

echo "2. Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
sleep 10 # Wait for ingress namespace briefly

echo "3. Patching Ingress Controller to use NodePort 30080..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
kubectl patch service ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30080}]'
sleep 5

echo "4. Deploying Database Tier..."
kubectl apply -f database.yaml

echo "5. Deploying Backend API Tier..."
kubectl apply -f backend.yaml

echo "6. Deploying Frontend Web Tier..."
kubectl apply -f frontend.yaml

echo "7. Creating Ingress Routing Rules..."
kubectl apply -f ingress.yaml

echo "8. Enforcing Database Network Policy..."
kubectl apply -f network-policy.yaml

echo "Deployment submitted! Waiting for pods to become ready..."
kubectl -n 3tier-app wait --for=condition=ready pod --all --timeout=120s
kubectl -n ingress-nginx wait --for=condition=ready pod --all --timeout=120s

echo "Success! The application stack is now running."
kubectl get all -n 3tier-app
kubectl get svc -n ingress-nginx
