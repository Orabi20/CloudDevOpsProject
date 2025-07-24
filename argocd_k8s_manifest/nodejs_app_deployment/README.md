
# Lab 24: Node.js Application Deployment with ClusterIP Service

This lab demonstrates how to deploy a Node.js application on Kubernetes using:
- Custom Docker image
- ConfigMap & Secret for MySQL credentials
- Toleration
- PersistentVolume
- ClusterIP Service

---

## 📁 Prerequisites

- Minikube running
- Docker image `orabi20/kubernetes-app:latest` pushed to Docker Hub
- Kubernetes namespace: `ivolve`

---

## 🔧 Step 1: Create Namespace

```bash
kubectl create namespace ivolve
```

---

## 🔐 Step 2: Create Secret and ConfigMap

```yaml
# mysql-configmap-secret.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: ivolve
data:
  DB_HOST: mysql-0.mysql.ivolve.svc.cluster.local
  DB_USER: ivolveuser
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: ivolve
type: Opaque
data:
  DB_PASSWORD: aXZvbHZlcGFzcw==            # base64 for 'ivolvepass'
  MYSQL_ROOT_PASSWORD: cm9vdHBhc3M=        # base64 for 'rootpass'
```

Apply it:

```bash
kubectl apply -f mysql-configmap-secret.yaml
```


## 🚀 Step 3: Deploy Node.js Application

```yaml
# deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
  namespace: ivolve
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nodejs
  template:
    metadata:
      labels:
        app: nodejs
    spec:
      tolerations:
        - key: "workload"
          operator: "Equal"
          value: "app"
          effect: "NoSchedule"
      containers:
        - name: nodejs-container
          image: orabi20/kubernetes:latest
          ports:
            - containerPort: 3000
          env:
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: mysql-config
                  key: DB_HOST
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
          volumeMounts:
            - name: logs-storage
              mountPath: /usr/src/app/data
      volumes:
        - name: logs-storage
          persistentVolumeClaim:
            claimName: app-logs-pvc
```

Apply it:

```bash
kubectl apply -f deployment.yaml
```
<img width="958" alt="24 7" src="https://github.com/user-attachments/assets/9847cd0f-5742-45db-a9b2-923cfcb5624b" />

<img width="947" alt="24 5" src="https://github.com/user-attachments/assets/bde48f06-8c37-445c-9037-9f86293c6755" />


---

## 📡 Step 5: Create ClusterIP Service

```yaml
# service.yml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-service
  namespace: ivolve
spec:
  selector:
    app: nodejs
  ports:
    - port: 3000
      targetPort: 3000
  type: ClusterIP
```

Apply it:

```bash
kubectl apply -f service.yaml
```
<img width="949" alt="24 6" src="https://github.com/user-attachments/assets/8248863e-33b5-4dc7-b633-e4d7a7bb7bd2" />

---

## 🧪 Step 6: Test via logs

```bash
kubectl logs -n ivolve -l app=nodejs
```
<img width="929" alt="image" src="https://github.com/user-attachments/assets/9ab7a9e2-8c0e-48cd-89ef-cd485d5b05b4" />

---


