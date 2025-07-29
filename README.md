
# DevOps CI/CD Pipeline on AWS EKS with Terraform, Jenkins, ArgoCD, and Ansible

## 📜 Overview

This project demonstrates a complete DevOps pipeline using **Terraform**, **Jenkins**, **ArgoCD**, **Ansible**, **Docker**, and **Kubernetes (EKS)**. It enables automatic provisioning, secure CI/CD, GitOps, and monitoring using modern DevOps tools on AWS infrastructure.

## 🧱 Architecture Summary

## 📁 Repository Structure

```
.
├── terraform/
├── ansible/
├── jenkins/
├── manifests/
├── monitoring/
└── README.md
```

- **Provisioning:** Terraform creates EKS, VPC, IAM, S3, and DynamoDB.
- **CI/CD:** Jenkins automates builds, tests, and deployment.
- **Containerization:** Docker used to build application images.
- **GitOps:** ArgoCD pulls updated manifests and syncs to EKS.
- **Monitoring:** Prometheus + Grafana monitor the entire setup.
- **Security:** Trivy scans images for vulnerabilities.
- **Automation:** Ansible provisions Jenkins and dependencies.

## 🔧 Tools and Technologies

| Tool        | Purpose                                 |
|-------------|------------------------------------------|
| Terraform   | Infrastructure as Code (IaC)            |
| Jenkins     | CI/CD orchestration                     |
| Docker      | Build container images                  |
| Trivy       | Security scanning of Docker images      |
| AWS EKS     | Managed Kubernetes cluster              |
| ArgoCD      | GitOps deployment engine                |
| Ansible     | Configuration management for Jenkins    |
| Prometheus  | Metrics scraping                        |
| Grafana     | Metrics visualization                   |
| GitHub      | Code + Manifest storage                 |



## 🌐 1. AWS Infrastructure (via Terraform)

- **EKS Cluster**
- **VPC with Public Subnets**
- **IAM roles for nodes and Jenkins**
- **S3 for remote state backend**
- **DynamoDB for state locking**

## 📜 Ansible Setup

Ansible is used to provision Jenkins:

- **Dynamic Inventory**: Auto-detect EC2 instances
- **Roles**:
  - Jenkins master setup
  - Jenkins slave agents
  - Docker, Java, and Trivy install
- **Playbooks**:
  - `setup-jenkins.yml`
  - `install-dependencies.yml`

Run:
```bash
ansible-playbook -i inventory/aws_ec2.yml playbooks/setup-jenkins.yml
```

## 🚀 CI/CD Pipeline Flow

1. **Developer pushes code to GitHub.**
2. Jenkins:
   - Pulls project repo and shared libraries
   - Logs in to AWS ECR
   - Builds and pushes Docker image
   - Runs Trivy vulnerability scan
   - Updates K8s deployment files in ArgoCD repo
3. **ArgoCD detects changes and syncs to the EKS cluster.**
4. **Application is deployed and running in EKS.**



## ☸️ Kubernetes Cluster Details

The EKS cluster hosts multiple namespaces:

| Namespace   | Description                                |
|-------------|--------------------------------------------|
| `default`   | Core system workloads and Helm releases     |
| `argocd`    | GitOps controller and UI                   |
| `ivolve`    | Application backend/frontend deployments    |
| `monitoring`| Prometheus and Grafana                     |

### App Deployment Structure (Namespace: `ivolve`)

- **Frontend & Backend Pods:** Auto-scaled deployments
- **Services:** ClusterIP and LoadBalancer
- **DB:** StatefulSet with persistent volumes
- **Init Containers:** Used for DB preparation or config jobs
- **Secrets & ConfigMaps:** Secure credentials and app configs
- **Ingress:** Optional for external access

## 📊 Monitoring and Dashboards

### Prometheus
- Deployed in `monitoring` namespace
- Scrapes metrics from nodes, pods, and Jenkins
- Uses `node-exporter` and `kube-state-metrics`

### Grafana
- Connected to Prometheus data source
- Dashboards included:
  - **Node Exporter Dashboard**
  - **EKS Cluster Overview**
  - **Jenkins Pipeline Metrics**

Access:
```
http://<grafana-lb-dns>:3000
Username: admin
Password: admin (or configured secret)
```

## 🌍 Website Access After Deployment

Once the app is deployed via ArgoCD, access it using the external Load Balancer DNS:

```bash
kubectl get svc -n ivolve
```

Look for the service with type `LoadBalancer`. You’ll see an external DNS like:

```
http://<your-app-lb>.amazonaws.com
```

If using Ingress, replace with:

```
http://<your-custom-domain>
```

Ensure DNS and security group rules allow HTTP/HTTPS traffic.





## ✅ Prerequisites

- AWS CLI configured
- `kubectl`, `eksctl`, `helm`
- Terraform installed
- Docker engine
- Ansible with `boto3`, `botocore`

## 📮 Contact

Raise issues via GitHub or contact the maintainer for queries.
