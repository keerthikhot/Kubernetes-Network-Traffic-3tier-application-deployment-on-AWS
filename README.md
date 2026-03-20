# 🚀 Kubernetes Network Traffic & 3-Tier Application Deployment on AWS

This repository contains the Infrastructure as Code (IaC) and Kubernetes manifest files to automatically provision, configure, and deploy a robust 3-tier application on a Kubernetes cluster hosted on AWS EC2 instances.

## 🏗️ Architecture Overview
This project completely automates your footprint in two major phases:

1. **Infrastructure Provisioning (Terraform)**: Dynamically sets up an AWS VPC, Security Groups, and two EC2 instances. It uses user-data scripts to bootstrap the foundation for the Kubernetes cluster.
2. **Application Deployment (Shell/Kubectl)**: Utilizes automated Bash scripts to securely copy Kubernetes manifest files to the newly provisioned EC2 instances, install the NGINX Ingress controller, and deploy the Database, Backend API, and Frontend web tier in a custom namespace.

## 🚦 How the Network Traffic Works
user requests -> ALB -> target group -> EC2 Host -> nodeport -> Ingress Controller -> Kube-proxy (iptables) -> CNI -> network namespace -> POD
The application uses a precisely configured Kubernetes networking model to securely route traffic between its tiers:
1. **External Access**: User traffic enters the AWS EC2 nodes via the public IP on NodePort `30080`.
2. **Ingress Routing**: The **NGINX Ingress Controller** intercepts this traffic.
   - User requests to the root path (`/`) are routed to the **Frontend** web service.
   - API requests to the (`/api`) path are routed to the **Backend** API service.
3. **Internal Architecture & Security**: The backend pods process requests and communicate with the isolated **Database** pod on port `6379`.
4. **Network Policies**: A strict Kubernetes `NetworkPolicy` (`redis-network-policy`) drops all traffic attempting to reach the database tier *except* connections originating explicitly from the backend pods.


## 🛠️ Tech Stack
* **Cloud Provider**: AWS (EC2, VPC)
* **Infrastructure as Code**: HashiCorp Terraform
* **Container Orchestration**: Kubernetes
* **Traffic Routing**: NGINX Ingress Controller
* **Automation Automation**: Bash Scripts (`scp`, `ssh`, `kubectl` wrappers)

## 📂 Project Structure
* `globals/` & `modules/`: Reusable Terraform modules that configure networking parameters and compute provisioning for AWS.
* `envs/prod/`: Environment-specific Terraform workspace. Contains state configurations and the `copy-and-deploy.sh` runner script.
* `k8s-app/`: Kubernetes manifest stack containing deployments & services (`frontend.yaml`, `backend.yaml`, `database.yaml`, `ingress.yaml`) and the internal cluster executor script (`deploy.sh`).

## ⚙️ Prerequisites
Before deploying, ensure you have the following installed locally:
* [Terraform](https://www.terraform.io/downloads.html)
* [AWS CLI](https://aws.amazon.com/cli/) locally configured (`aws configure`)
* The appropriate `.pem` SSH keys ready locally (Ensure the key path is correctly mapped inside `envs/prod/copy-and-deploy.sh`).

## 🚀 Deployment Instructions

### 1. Provision the Cloud Infrastructure
Navigate to the production workspace and trigger Terraform to build the AWS resources:
```bash
cd envs/prod
terraform init
terraform plan
terraform apply --auto-approve
```

### 2. Deploy the Kubernetes Services
Once Terraform completes and the EC2 instances are running, push the K8s configuration to deploy the 3-tier application:
```bash
./copy-and-deploy.sh
```
*This script querys AWS for the new backend IPs, synchronizes the `k8s-app/` directory via SCP, and systematically brings up the workloads.*

### 3. Verify the Deployment
You can SSH into your designated node host and verify the network traffic policies and pods:
```bash
kubectl get all -n 3tier-app
kubectl get ingress -n 3tier-app
```

## 🧹 Cleanup
To avoid incurring unnecessary AWS costs, tear down the infrastructure when finished:
```bash
cd envs/prod
terraform destroy --auto-approve
```
*(Note: Attempting a `terraform destroy` will completely delete the active Kubernetes cluster and resulting application data.)*

---

## 👨‍💻 Author
**Shrutkirti Sanjay Khot**
