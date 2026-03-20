#!/bin/bash
set -e

echo "Fetching new IP addresses from Terraform outputs..."
BASTION_IP=$(terraform output -raw bastion_public_ip)

# Querying AWS for the new private IPs of our nodes based on the tags
NODE0_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=prod-node-0" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
NODE1_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=prod-node-1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)

KEY_FILE="$HOME/Downloads/was-default.pem"

if count=$(ls -1 $KEY_FILE 2>/dev/null | wc -l); then
    if [ "$count" -eq 0 ]; then
        echo "Error: Cannot find SSH key at $KEY_FILE. Please update script with correct path."
        exit 1
    fi
fi

chmod 400 $KEY_FILE

SSH_OPTS=(
  -o StrictHostKeyChecking=no
  -o "ProxyCommand=ssh -W %h:%p -q -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$BASTION_IP"
  -i "$KEY_FILE"
)

echo "Copying files to Node 0 ($NODE0_IP)..."
scp "${SSH_OPTS[@]}" -r ../../k8s-app ubuntu@$NODE0_IP:/home/ubuntu/

echo "Copying files to Node 1 ($NODE1_IP)..."
scp "${SSH_OPTS[@]}" -r ../../k8s-app ubuntu@$NODE1_IP:/home/ubuntu/

echo "Deploying on Node 0..."
ssh "${SSH_OPTS[@]}" ubuntu@$NODE0_IP "cd k8s-app && chmod +x deploy.sh && sudo chmod +x deploy.sh && ./deploy.sh"

echo "Deploying on Node 1..."
ssh "${SSH_OPTS[@]}" ubuntu@$NODE1_IP "cd k8s-app && chmod +x deploy.sh && sudo chmod +x deploy.sh && ./deploy.sh"

echo "Done!"
