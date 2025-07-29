# ArgoCD Kubernetes Deployment

This project contains Kubernetes configuration files for deploying a full-stack application using ArgoCD. It includes resources for an application deployment and a MySQL database managed as a StatefulSet.

---

## 📁 Project Structure

```
argocd/
├── deployment.yml              # Main application Deployment
├── init_deployment.yml         # Init container Deployment (for DB setup)
├── msql_statefulset.yml        # MySQL StatefulSet
├── mysql_headless_service.yml  # Headless Service for MySQL clustering
├── service.yml                 # Service to expose the application
```

---

## ⚙️ Kubernetes Resources Explained

### `deployment.yml`
**Purpose:** Defines the main application deployment using a `Deployment` resource in Kubernetes.

**Key elements:**
- Number of replicas
- Docker image details

### `init_deployment.yml`
**Purpose:** Runs one or more init containers before the main application starts.

### `msql_statefulset.yml`
**Purpose:** Deploys MySQL as a StatefulSet.

### `mysql_headless_service.yml`
**Purpose:** Enables direct DNS access to StatefulSet pods.

### `service.yml`
**Purpose:** Exposes your application (LoadBalancer).

---
