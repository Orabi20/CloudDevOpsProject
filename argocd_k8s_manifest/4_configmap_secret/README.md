# Lab 21: Managing Configuration and Sensitive Data with ConfigMaps and Secrets

This lab demonstrates how to manage configuration data and sensitive credentials for a MySQL setup in Kubernetes using ConfigMaps and Secrets.

---

## 🎯 Objectives

- Store **non-sensitive MySQL configuration** in a ConfigMap
- Store **sensitive MySQL credentials** in a Secret using base64 encoding

---

## 🧾 Resources

### ✅ ConfigMap: `mysql-config`

Stores non-sensitive data:

| Key      | Value            |
|----------|------------------|
| DB_HOST  | mysql-service    |
| DB_USER  | ivolveuser       |

Command to view:
```bash
kubectl describe configmap mysql-config -n ivolve
```

---

### 🔐 Secret: `mysql-secret`

Stores sensitive data (base64 encoded):

| Key                 | Value (decoded) |
|---------------------|-----------------|
| DB_PASSWORD         | ivolvepass      |
| MYSQL_ROOT_PASSWORD | rootpass        |

Command to decode:
```bash
echo aXZvbHZlcGFzcw== | base64 --decode
echo cm9vdHBhc3M= | base64 --decode
```

Command to view:
```bash
kubectl get secret mysql-secret -n ivolve -o yaml
```

---

## 🛠️ Apply the ConfigMap and Secret

```bash
kubectl apply -f lab21-mysql-config.yaml
```

Ensure the `ivolve` namespace exists:
```bash
kubectl create namespace ivolve
```

---

## 📌 Note

- Secrets must be referenced securely in Pods or Deployments.
- Avoid committing raw secrets (in base64 or plaintext) to public repositories.

