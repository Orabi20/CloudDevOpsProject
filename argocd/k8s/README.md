# ArgoCD Kubernetes Deployment

This project contains Kubernetes configuration files for deploying a full-stack application using ArgoCD. It includes resources for an application deployment and a MySQL database managed as a StatefulSet.

---

## 📁 Project Structure

```
argocd/
├── deployment.yml               # Main application Deployment
├── init_deployment.yml         # Init container Deployment (for setup/bootstrap tasks)
├── msql_statefulset.yml        # MySQL StatefulSet (persistent database)
├── mysql_headless_service.yml  # Headless Service for MySQL clustering
├── service.yml                 # Service to expose the application
```

---

## 🚀 Deployment Instructions

1. **Install ArgoCD on your cluster (if not already installed)**:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Access ArgoCD UI**:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   Navigate to `https://localhost:8080`.

3. **Login to ArgoCD CLI**:
   ```bash
   argocd login localhost:8080
   ```

4. **Create ArgoCD Application**:
   ```bash
   argocd app create my-app \
     --repo <your-repo-url> \
     --path argocd \
     --dest-server https://kubernetes.default.svc \
     --dest-namespace default
   ```

5. **Sync the Application**:
   ```bash
   argocd app sync my-app
   ```

---

## ⚙️ Kubernetes Resources Explained

### `deployment.yml`
**Purpose:** Defines the main application deployment using a `Deployment` resource in Kubernetes.

**Key elements:**
- Number of replicas
- Docker image details
- Resource limits and environment variables

### `init_deployment.yml`
**Purpose:** Runs one or more init containers before the main application starts.

**Use Case:** Prepares the environment (e.g., DB migrations or config setup).

### `msql_statefulset.yml`
**Purpose:** Deploys MySQL as a StatefulSet.

**Use Case:** Ensures persistence and stable identities for MySQL pods.

### `mysql_headless_service.yml`
**Purpose:** Enables direct DNS access to StatefulSet pods.

**Use Case:** Supports clustered MySQL communication via DNS.

### `service.yml`
**Purpose:** Exposes your application (LoadBalancer, NodePort, or ClusterIP).

**Use Case:** Allows users or services to access your app.

---

## 📈 Monitoring & Logging

Integrate tools like:

- **Prometheus & Grafana** for metrics and dashboards.
- **Loki/EFK stack** for logging.
- **ArgoCD Metrics**: Add these flags to ArgoCD components:
  ```yaml
  - --metrics
  - --metrics-port=8082
  ```

Then configure Prometheus to scrape metrics.

---

## 🌐 Accessing the Application

Depends on `service.yml`:

- **NodePort**:
  ```
  http://<node-ip>:<node-port>
  ```

- **LoadBalancer**:
  ```bash
  kubectl get svc
  ```

- **Ingress** (if configured):
  ```
  http://<your-domain>
  ```

---

## 📋 Summary Table

| File Name                 | Resource Type     | Description                                      |
|--------------------------|-------------------|--------------------------------------------------|
| `deployment.yml`         | Deployment        | Runs the main application                        |
| `init_deployment.yml`    | Deployment        | Bootstrap/init containers before main app starts |
| `msql_statefulset.yml`   | StatefulSet       | Deploys MySQL with persistent storage            |
| `mysql_headless_service.yml` | Headless Service | Enables direct pod access for MySQL              |
| `service.yml`            | Service           | Exposes the main app internally or externally    |

---

## 📝 Notes

- Update image tags and repository URLs before deploying.
- Persistent Volumes must be pre-configured in your cluster.
- Secure MySQL credentials using Kubernetes Secrets.
