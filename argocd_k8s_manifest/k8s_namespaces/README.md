# Lab 20: Namespace Management and Resource Quota Enforcement

## 🎯 Objective

- Create a Kubernetes namespace called `ivolve`.
- Enforce a resource quota that limits the number of pods in this namespace to **2**.

---

## 📁 Resources

All configurations are defined in a single YAML file: `lab20-namespace-quota.yaml`.

---

## 📦 File: `lab20-namespace-quota.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ivolve
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pod-limit
  namespace: ivolve
spec:
  hard:
    pods: "2"
```

---

## 🛠️ Apply Configuration

```bash
kubectl apply -f lab20-namespace-quota.yaml
```

<img width="952" alt="20 1" src="https://github.com/user-attachments/assets/6b1baf4f-d903-440c-860b-fc6cf9328fc0" />


<img width="958" alt="20 2" src="https://github.com/user-attachments/assets/9b5ece9f-3ad2-4a54-8c7f-95e248b03d24" />



---

## ✅ Verify

### Check namespace:
```bash
kubectl get namespaces
```
<img width="947" alt="20 3" src="https://github.com/user-attachments/assets/6d05c04e-8e21-47b4-8338-5dd4239e41c1" />


### Check resource quota in the namespace:
```bash
kubectl get resourcequota -n ivolve
kubectl describe resourcequota pod-limit -n ivolve
```

<img width="958" alt="20 4" src="https://github.com/user-attachments/assets/10e61417-5524-4bc2-a9fb-e006ddf715f8" />


---

## 🔍 Test the Quota

Try creating more than 2 pods inside the `ivolve` namespace. The third pod should be **blocked** with a message indicating that the resource quota has been exceeded.

---

## 🧹 Cleanup (Optional)

```bash
kubectl delete namespace ivolve
```

---

## 📌 Notes

- Resource quotas help control resource consumption in multi-tenant environments.
- This example enforces a **hard limit** on the number of pods.
