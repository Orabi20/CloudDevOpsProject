# Lab 25: Kubernetes Init Container for Pre-Deployment Database Setup

## 🎯 Objective

Set up an `initContainer` in a Kubernetes deployment to:

- Create the `ivolve` MySQL database
- Create a new MySQL user with full access to that database
- Ensure this runs **before** the main application container starts

---

## 🛠 Prerequisites

- Kubernetes cluster is running (e.g., Minikube)
- MySQL database deployed and accessible via a Service (e.g., `mysql`)
- Namespace `ivolve` is created

---

## 📁 Files Needed

### 1. `deployment.yaml`
Includes the init container and the main container.

See sample snippet:

```yaml
initContainers:
  - name: init-mysql-setup
    image: mysql:5.7
    env:
      - name: DB_HOST
        valueFrom:
          configMapKeyRef:
            name: mysql-config
            key: DB_HOST
      - name: MYSQL_ROOT_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-secret
            key: MYSQL_ROOT_PASSWORD
      - name: DB_USER
        valueFrom:
          configMapKeyRef:
            name: mysql-config
            key: DB_USER
      - name: DB_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-secret
            key: DB_PASSWORD
    command: ["sh", "-c"]
    args:
      - |
        echo "Waiting for MySQL to be ready..."
        until mysqladmin ping -h $DB_HOST --silent; do
          echo "Waiting for MySQL..."
          sleep 2
        done
        echo "Creating database and user..."
        mysql -h $DB_HOST -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
          CREATE DATABASE IF NOT EXISTS ivolve;
          CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
          GRANT ALL PRIVILEGES ON ivolve.* TO '${DB_USER}'@'%';
          FLUSH PRIVILEGES;";
        echo "Init container completed."
```

---

## 🚀 Apply the Resources

```bash
kubectl apply -f init_deployment.yml
```

---

## 🧪 Verify

### 1. Check pod status:
```bash
kubectl get pods -n ivolve
```
<img width="944" alt="25 2" src="https://github.com/user-attachments/assets/a035cc04-e15b-4dfd-9527-90137bca43d6" />

### 2. View init container logs:
```bash
kubectl logs <pod-name> -c init-mysql-setup -n ivolve
```

Should show:
```
Creating database and user...
Init container completed.
```
<img width="950" alt="25 1" src="https://github.com/user-attachments/assets/98e4938e-8022-484c-9a8b-330543b0856e" />

## 🧪 Test via Port Forwarding

```bash
kubectl port-forward svc/nodejs-service 8080:80 -n ivolve
```
<img width="952" alt="24 4" src="https://github.com/user-attachments/assets/b84f4d3b-749b-41e3-ae4f-61bddd0acdfe" />

Then open your browser and go to:

```
http://localhost:8080
```
<img width="959" alt="24 1" src="https://github.com/user-attachments/assets/a9606e53-d817-4abb-a278-8a6d58c45bc8" />

<img width="269" alt="24 2" src="https://github.com/user-attachments/assets/941fc06e-3fd9-4ea6-94b9-f1658bf9d7ac" />

<img width="266" alt="24 3" src="https://github.com/user-attachments/assets/6206c9b5-cf8f-4ba6-8e80-439304ae6544" />



---

## ✅ Outcome

- Init container runs once per pod creation
- Database `ivolve` and user `ivolve_user` created
- Main application starts only **after** DB setup is complete
