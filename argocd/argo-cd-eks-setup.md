
# 🚀 Argo CD Setup on Amazon EKS

This guide will walk you through deploying **Argo CD** on an **Amazon EKS cluster**, including steps for correct subnet tagging and service exposure.

---

## 📋 Prerequisites

- ✅ An existing EKS Cluster
- ✅ `kubectl` configured for EKS
- ✅ `awscli` configured with access to your EKS VPC
- ✅ `eksctl` or Terraform (if you provisioned the cluster)
- ✅ Helm (optional, for advanced usage)

---

## 1️⃣ Tag Public Subnets for LoadBalancer

### 🔍 Find Your Subnets

Run this command:

```bash
aws ec2 describe-subnets   --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Tags:Tags}"   --output table
```

Identify the **public subnets** (those with a route to an Internet Gateway).

### ✅ Add Required Tags

Replace `<subnet-id>` and `<cluster-name>`:

```bash
aws ec2 create-tags --resources <subnet-id>   --tags Key=kubernetes.io/cluster/<cluster-name>,Value=owned          Key=kubernetes.io/role/elb,Value=1
```

Repeat for all **public subnets**.

---

## 2️⃣ Create Namespace for Argo CD

```bash
kubectl create namespace argocd
```

---

## 3️⃣ Install Argo CD

Apply the official Argo CD manifest:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verify pods are running:

```bash
kubectl get pods -n argocd
```

---

## 4️⃣ Expose Argo CD UI with LoadBalancer

Patch the service to use a LoadBalancer:

```bash
kubectl patch svc argocd-server -n argocd   -p '{"spec": {"type": "LoadBalancer"}}'
```

Wait a few minutes, then run:

```bash
kubectl get svc argocd-server -n argocd
```

You’ll get an EXTERNAL-IP like:

```
argocd-server   LoadBalancer   <internal-ip>   a12b34c56d7e8f9g.elb.amazonaws.com   80:XXXXX/TCP,443:YYYYY/TCP
```

---

## 5️⃣ Access Argo CD UI

Open your browser and navigate to:

```
http://<EXTERNAL-IP>
or
https://<EXTERNAL-IP>
```

---

## 6️⃣ Log in to Argo CD

### 🧑‍💻 Get the Initial Admin Password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d
```

- **Username**: `admin`
- **Password**: *(output of the above command)*

---

## ✅ Done!

You now have Argo CD running on EKS and accessible via ELB. You can now start creating `Application` manifests or connect Argo CD to your GitOps repository.

---

## 🧹 Optional Cleanup

To delete Argo CD:

```bash
kubectl delete ns argocd
```

---

## 📘 References

- [Official Argo CD Docs](https://argo-cd.readthedocs.io/)
- [AWS EKS Load Balancer Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/)
