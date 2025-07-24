
# Lab 23: MySQL StatefulSet Deployment with Headless Service

This lab demonstrates how to deploy a MySQL database using a Kubernetes StatefulSet and a Headless Service in the `ivolve` namespace.

---

## 📁 Files Included

- `mysql-headless-service.yaml` — Headless Service to expose StatefulSet pods.
- `mysql-statefulset.yaml` — StatefulSet that runs MySQL with persistent volumes and toleration.

---

## ⚙️ Step-by-Step Instructions

### 1. ✅ Namespace
Ensure the namespace `ivolve` exists:

```bash
kubectl create namespace ivolve
```

> If already created, skip this step.

---

### 2. 🔐 Create MySQL Secret

**mysql-secret.yaml**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secrets
  namespace: ivolve
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: my-secret-password
```

Apply:

```bash
kubectl apply -f mysql-secret.yaml
```

---

### 3. 🌐 Create Headless Service

**mysql-headless-service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: ivolve
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

Apply:

```bash
kubectl apply -f mysql-headless-service.yaml
```

---

### 4. 📦 Deploy StatefulSet

**mysql-statefulset.yaml**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: ivolve
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      tolerations:
      - key: "workload"
        operator: "Equal"
        value: "database"
        effect: "NoSchedule"
      containers:
      - name: mysql
        image: mysql:5.7
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_ROOT_PASSWORD
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

Apply:

```bash
kubectl apply -f mysql-statefulset.yaml
```
<img width="944" alt="23 1" src="https://github.com/user-attachments/assets/de5b2263-721a-4c29-9694-fe8dc80e75b8" />

<img width="946" alt="23 2" src="https://github.com/user-attachments/assets/81790501-ac18-4fc6-8a65-8043d2545e1b" />


---

### 5. ✅ Verify Everything

```bash
kubectl get pods -n ivolve
kubectl get svc -n ivolve
kubectl get pvc -n ivolve
```
<img width="954" alt="23 3" src="https://github.com/user-attachments/assets/5daf3f8c-bedb-4b5f-98b5-923a3ab4a18d" />

<img width="950" alt="23 4" src="https://github.com/user-attachments/assets/cb1f8a27-cf9f-4595-b74d-4ee276ddb590" />

<img width="947" alt="23 5" src="https://github.com/user-attachments/assets/0581f75a-8c69-48af-969f-5c945d2859d8" />

<img width="950" alt="23 6" src="https://github.com/user-attachments/assets/39d60a0c-8c4a-4635-a60a-1d413c8f96c2" />



---

### 6. 🧪 Connect to MySQL

```bash
kubectl exec -it -n ivolve mysql-0 -- mysql -u root -p
```

Then enter `my-secret-password`

List databases:

```sql
SHOW DATABASES;
```
<img width="947" alt="23 8" src="https://github.com/user-attachments/assets/4785ea12-12da-401a-9b80-8d6c45136e90" />

---

### 7. 🔍 Test DNS (Headless)

```bash
kubectl exec -it -n ivolve mysql-0 -- getent hosts mysql
```

Expected DNS:
```
mysql-0.mysql.ivolve.svc.cluster.local
```
<img width="950" alt="image" src="https://github.com/user-attachments/assets/e68ada7f-5a50-4b2d-8a56-6c802de860c5" />

---

## ✅ Summary

- **StatefulSet** gives stable pod names and persistent storage.
- **Headless Service** gives pod-level DNS discovery.
- **Secret** protects sensitive credentials.
