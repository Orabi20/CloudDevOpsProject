
# 📊 Monitoring EKS with Prometheus & Grafana

This guide explains how to install and configure Prometheus and Grafana on your Amazon EKS cluster using Helm charts.

---

## 🚀 Prerequisites

- ✅ EKS Cluster up and running (`kubectl` configured)
- ✅ Helm installed
- ✅ Namespace: `monitoring` created
- ✅ AWS CLI configured (optional for LoadBalancer access)

---

## 📁 Step 1: Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

---

## 📦 Step 2: Add Helm Repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

---

## ⚙️ Step 3: Create Custom `values.yaml`

Create a `values.yaml` file with the following content:

```yaml
alertmanager:
  enabled: true
  alertmanagerSpec:
    replicas: 1
    storage: {}  # Disables PVC
    tolerations:
      - key: "workload"
        operator: "Exists"
        effect: "NoSchedule"

server:
  service:
    type: LoadBalancer
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"
  persistentVolume:
    enabled: false
  extraVolumes:
    - name: data-volume
      emptyDir: {}
  extraVolumeMounts:
    - name: data-volume
      mountPath: /prometheus

nodeExporter:
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"

kubeStateMetrics:
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"

pushgateway:
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"
```

Save as `values.yaml`.

---

## 📈 Step 4: Install Prometheus Stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack   -n monitoring -f values.yaml
```

✅ This installs:
- Prometheus
- Alertmanager
- node-exporter
- kube-state-metrics
- Pushgateway
- Grafana (included in the stack)

---

## 🧠 Optional: Install Grafana Separately

You can optionally install Grafana standalone with SMTP config.

1. Create `grafana-values.yaml`:

```yaml
adminPassword: "admin"

smtp:
  enabled: true
  host: smtp.example.com:587
  user: you@example.com
  password: yourpassword
  fromAddress: alerts@example.com
  fromName: Prometheus Alertmanager

tolerations:
  - key: "workload"
    operator: "Exists"
    effect: "NoSchedule"

service:
  type: LoadBalancer
```

2. Install with Helm:

```bash
helm install grafana grafana/grafana -n monitoring -f grafana-values.yaml
```

---

## 🔐 Step 5: Access Grafana Dashboard

```bash
kubectl get svc -n monitoring
```

Look for `grafana` service with `EXTERNAL-IP`.

Open in browser: `http://<EXTERNAL-IP>:3000`

Default credentials:
- **User:** `admin`
- **Password:** `admin` or from:
  
  ```bash
  kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```

---

## 📬 Step 6: (Optional) Setup Email Alerts via Alertmanager

Create `alertmanager-config.yaml`:

```yaml
global:
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alerts@example.com'
  smtp_auth_username: 'you@example.com'
  smtp_auth_password: 'yourpassword'

route:
  receiver: 'email-alerts'

receivers:
  - name: 'email-alerts'
    email_configs:
      - to: 'recipient@example.com'
        send_resolved: true
```

Apply:

```bash
kubectl create secret generic alertmanager-prometheus-kube-prometheus-alertmanager   --from-file=alertmanager.yaml=alertmanager-config.yaml   -n monitoring --dry-run=client -o yaml | kubectl apply -f -
```

Restart Alertmanager Pod:

```bash
kubectl delete pod -l app.kubernetes.io/name=alertmanager -n monitoring
```

---

## 📊 Dashboard Setup in Grafana

Once Grafana is running:

1. Log in to Grafana
2. Go to **Configuration → Data Sources**
3. Add Prometheus with URL: `http://prometheus-operated.monitoring.svc:9090`
4. Import dashboard IDs from https://grafana.com/grafana/dashboards

---

## ✅ Troubleshooting

- ❗ **Pod Pending**:
  - Check PVCs: `kubectl get pvc -n monitoring`
  - Check node taints: `kubectl describe node`
  - Disable persistence (`storage: {}`) or use `emptyDir`

- ❗ **Service has no EXTERNAL-IP**:
  - Use port-forwarding instead:
    ```bash
    kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
    ```

---

## 📌 Useful Commands

```bash
kubectl get all -n monitoring
helm list -n monitoring
kubectl logs -f <pod-name> -n monitoring
```

---

## 🎉 Done!

You now have full monitoring set up on EKS with Prometheus, Grafana, and optional email alerting!
