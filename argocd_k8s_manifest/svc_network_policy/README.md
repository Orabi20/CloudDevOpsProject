
# Lab 28: Control Pod-to-Pod Traffic via Network Policy

## 🎯 Objective
Allow only application pods to access MySQL pods on port **3306**. Deny all other pod-to-pod traffic.

---

## 🛠️ Steps


### Step 1: Apply NetworkPolicy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-to-mysql
  namespace: ivolve
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nodejs
      ports:
        - protocol: TCP
          port: 3306
```

> Apply it:
```bash
kubectl apply -f network-policy.yml
```

<img width="950" height="82" alt="28 1" src="https://github.com/user-attachments/assets/4616fbf9-51d2-4082-bd35-6287b86a514e" />


---

### Step 2: Verify the Policy


```bash
kubectl describe networkpolicy allow-app-to-mysql -n ivolve
```

<img width="948" height="404" alt="28 2" src="https://github.com/user-attachments/assets/b92bf5ae-ce6b-4379-8060-5f809986826a" />


---

## 🔒 Note on Ports
NetworkPolicy only allows traffic to destination port `3306`.  
If a request from the Node.js app tries to reach MySQL on **another port (e.g., 2000)**, it will be **blocked**.

Also, MySQL only listens on port `3306`, so connections to other ports will fail regardless.

---

## ✅ Summary
| Source Pod Label | Destination Port | Allowed |
|------------------|------------------|---------|
| app=nodejs       | 3306             | ✅ Yes  |
| app=nodejs       | 2000             | ❌ No   |
| other pods       | 3306             | ❌ No   |
| other pods       | 2000             | ❌ No   |

---
