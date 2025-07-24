# Lab 19: Node Isolation Using Taints in Kubernetes

## 🧪 Objective
Isolate Kubernetes workloads by tainting nodes to restrict pod scheduling unless explicitly tolerated.

---

## ⚙️ Lab Setup

- Kubernetes cluster with **3 nodes**
  - Tools: Minikube (multi-node), kubeadm, EKS, etc.

---

## 🛠️ Steps

### 1. Start a 3-node Kubernetes Cluster
Example using Minikube:
```bash
minikube start --nodes 3 -p taint-lab
kubectl get nodes
```

---

### 2. Taint Nodes

#### 🔹 Taint Node 1 (Master Node)
```bash
kubectl taint nodes <node-name-1> workload=master:NoSchedule
```

#### 🔹 Taint Node 2 (App Node)
```bash
kubectl taint nodes <node-name-2> workload=app:NoSchedule
```

#### 🔹 Taint Node 3 (Database Node)
```bash
kubectl taint nodes <node-name-3> workload=database:NoSchedule
```

<img width="929" alt="19 2" src="https://github.com/user-attachments/assets/2fe43e72-84c5-4f6a-9bb0-9f653e4a61f8" />


---

### 3. Verify Taints
```bash
kubectl describe nodes | grep -i taint
```

<img width="952" alt="19 3" src="https://github.com/user-attachments/assets/6d18aca1-1a86-40bc-9b0b-49ff0f8ae1a3" />


---

## 📘 Taint Effect Types

| Effect Type        | Description                                          |
|--------------------|------------------------------------------------------|
| `NoSchedule`       | Prevents scheduling pods that don't tolerate taint   |
| `PreferNoSchedule` | Tries to avoid scheduling, but may allow it          |
| `NoExecute`        | Evicts existing pods and prevents new ones           |

---
