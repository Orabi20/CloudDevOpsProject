# Kubernetes Deployment

This project contains Kubernetes configuration files for deploying a full-stack application using ArgoCD. It includes resources for an application deployment and a MySQL database managed as a StatefulSet.

---

## 📁 Project Structure

```
argocd/
├── configmap.yml               # Set Configmap and Secerts for Cluster
├── deployment.yml              # Main application Deployment
├── init_deployment.yml         # Init container Deployment (for DB setup)
├── msql_statefulset.yml        # MySQL StatefulSet
├── mysql_headless_service.yml  # Headless Service for MySQL clustering
├── service.yml                 # Service to expose the application
```

---

## ⚙️ Kubernetes Resources Explained

### `configmap.yml`
- Store non-sensitive MySQL configuration in a ConfigMap
- Store sensitive MySQL credentials in a Secret using base64 encoding

### `deployment.yml`
Defines the main application deployment using a `Deployment` resource in Kubernetes.

### `init_deployment.yml`
Runs one or more init containers before the main application starts.

### `msql_statefulset.yml`
Deploys MySQL as a StatefulSet.

### `mysql_headless_service.yml`
Enables direct DNS access to StatefulSet pods.

### `service.yml`
Exposes application via (LoadBalancer).

---
