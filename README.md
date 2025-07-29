
# DevOps CI/CD Pipeline on AWS EKS with Terraform, Jenkins, ArgoCD, and Ansible

## 📜 Overview

This project demonstrates a complete DevOps pipeline using **Terraform**, **Jenkins**, **ArgoCD**, **Ansible**, **Docker**, and **Kubernetes (EKS)**. It enables automatic provisioning, secure CI/CD, GitOps, and monitoring using modern DevOps tools on AWS infrastructure.


<img width="799" height="392" alt="image" src="https://github.com/user-attachments/assets/a9780051-1a5c-4344-a228-fb0088b82137" />


## 📁 Repository Structure

```
.
├── terraform/
├── ansible/
├── nodejs_app/
├── jenkins/
├── argocd/
├── monitor/
└── README.md
```
---
## 🧱 Architecture Summary

- **Provisioning:** Terraform creates EKS, VPC, IAM, S3, and DynamoDB.
- **CI/CD:** Jenkins automates builds, tests, and deployment.
- **Containerization:** Docker used to build application images.
- **GitOps:** ArgoCD pulls updated manifests and syncs to EKS.
- **Monitoring:** Prometheus + Grafana monitor the entire setup.
- **Security:** Trivy scans images for vulnerabilities.
- **Automation:** Ansible provisions Jenkins and dependencies.
---
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


---
## 🌐 1. AWS Infrastructure (via Terraform)

- **EKS Cluster**
- **VPC with Public Subnets**
- **IAM roles for nodes and Jenkins**
- **S3 for remote state backend**
- **DynamoDB for state locking**

---
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
---

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

<img width="934" height="234" alt="image" src="https://github.com/user-attachments/assets/6cee12b4-3249-4dd9-aef6-575018edf7d3" />

---

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
<img width="752" height="323" alt="ar 3" src="https://github.com/user-attachments/assets/1d4265a1-4a9b-49e0-9586-1901fde917f8" />

<img width="598" height="147" alt="ar 4" src="https://github.com/user-attachments/assets/be6e5f76-4013-4f0c-a870-1a0ff1efbde3" />


---
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


<img width="944" height="451" alt="mo 4" src="https://github.com/user-attachments/assets/b966d6d8-5354-4006-9fc2-ec1f706cce15" />

<img width="945" height="440" alt="mo 5" src="https://github.com/user-attachments/assets/8a337fed-95c8-430a-840b-a38439898e14" />

<img width="949" height="419" alt="mo 6" src="https://github.com/user-attachments/assets/f7516488-b421-4c1e-a0be-e7295729f3d7" />

<img width="944" height="441" alt="mo 7" src="https://github.com/user-attachments/assets/43196573-2f0a-4ed1-851e-3f1cadc6dc90" />

---
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


<img width="959" height="438" alt="image" src="https://github.com/user-attachments/assets/82fa0ad1-3752-487f-945f-ec1703d7ccee" />
