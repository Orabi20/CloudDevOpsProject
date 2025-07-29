
# Argo CD Setup on Amazon EKS

This guide will walk you through deploying **Argo CD** on an **Amazon EKS cluster**, including steps service exposure.

<img width="1598" height="783" alt="Screenshot 2025-07-29 154525" src="https://github.com/user-attachments/assets/d7c088db-b4e2-47c6-8ba5-138268028a12" />

---

## Prerequisites

-  An existing EKS Cluster
-  `kubectl` configured for EKS
-  `awscli` configured with access to your EKS VPC

---


## 1. Create Namespace for Argo CD

```bash
kubectl create namespace argocd
```

---

## 2. Install Argo CD

Apply the official Argo CD manifest:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verify pods are running:

```bash
kubectl get pods -n argocd
```
<img width="929" height="189" alt="image" src="https://github.com/user-attachments/assets/22f71134-d451-45f2-93c1-acdf50819af1" />

---

## 3. Expose Argo CD UI with LoadBalancer

Patch the service to use a LoadBalancer:

```bash
kubectl patch svc argocd-server -n argocd   -p '{"spec": {"type": "LoadBalancer"}}'
```

Wait a few minutes, then run:

```bash
kubectl get svc argocd-server -n argocd
```

You’ll get an EXTERNAL-IP like:

<img width="947" height="40" alt="image" src="https://github.com/user-attachments/assets/6c2bed0f-d6e9-4654-9a34-13ce15cc73bb" />

---

## 4. Access Argo CD UI

Open your browser and navigate to:

```
http://a12b34c56d7e8f9g.elb.amazonaws.com
```

---

## 5. Log in to Argo CD

### Get the Initial Admin Password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d
```

- **Username**: `admin`
- **Password**: *(output of the above command)*

---

## ✅ Done!

You now have Argo CD running on EKS and accessible via ELB. You can now start creating `Application` manifests or connect Argo CD to your GitOps repository.

<img width="945" height="411" alt="image" src="https://github.com/user-attachments/assets/3781bd8f-9e1b-4485-b10f-03cea4badfe5" />


---
