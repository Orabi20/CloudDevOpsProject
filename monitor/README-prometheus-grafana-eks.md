# 📊 Monitoring EKS with Prometheus & Grafana

This guide explains how to install and configure Prometheus and Grafana on your Amazon EKS cluster using Helm charts.

---

##  Prerequisites

-  EKS Cluster up and running (`kubectl` configured)
-  Helm installed
-  Namespace: `monitoring` created
-  AWS CLI configured

---

## Step 1: Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

---

## Step 2: Add Helm Repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

---

## Step 3: Create Custom `prometheus.yaml`

Create a `prometheus.yaml` file with the following content:

```yaml
alertmanager:
  enabled: false
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"

kubeStateMetrics:
  enabled: true
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"

nodeExporter:
  enabled: true
  tolerations:
    - key: "workload"
      operator: "Exists"
      effect: "NoSchedule"

pushgateway:
  enabled: true
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
  args:
    - "--storage.tsdb.retention.time=15d"
    - "--config.file=/etc/config/prometheus.yml"
    - "--storage.tsdb.path=/prometheus"
    - "--web.console.libraries=/etc/prometheus/console_libraries"
    - "--web.console.templates=/etc/prometheus/consoles"
    - "--web.enable-lifecycle"
  securityContext:
    runAsUser: 65534
    runAsGroup: 65534
    fsGroup: 65534
```

Save as `prometheus.yaml`.

---

## 📈 Step 4: Install Prometheus Stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack   -n monitoring -f prometheus.yaml
```

*This installs:
- Prometheus
- Alertmanager
- node-exporter
- kube-state-metrics
- Pushgateway

<img width="958" height="448" alt="image" src="https://github.com/user-attachments/assets/1baebfa3-8caf-4ae9-911c-43474adbf910" />


---

## Install Grafana Separately

You can optionally install Grafana standalone with SMTP config.

1. Create `grafana-values.yaml`:

```yaml
replicaCount: 1

tolerations:
  - key: "workload"
    operator: "Exists"

persistence:
  enabled: false

service:
  type: LoadBalancer
  port: 80
  targetPort: 3000

admin:
  user: admin
  password: admin123

securityContext:
  runAsUser: 472
  runAsGroup: 472
  fsGroup: 472

```

2. Install with Helm:

```bash
helm install grafana grafana/grafana -n monitoring -f grafana-values.yaml
```

---

## Step 5: Access Grafana Dashboard

```bash
kubectl get svc -n monitoring
```
<img width="828" height="99" alt="image" src="https://github.com/user-attachments/assets/1936e2b0-48ed-4929-a97b-7da68031c4ca" />

Look for `grafana` service with `EXTERNAL-IP`.



Default credentials:
- **User:** `admin`
- **Password:** `admin123` or from:
  
  ```bash
  kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```

<img width="947" height="424" alt="image" src="https://github.com/user-attachments/assets/6acb617e-a01f-49de-94a6-950866e54e2d" />

---


## Dashboard Setup in Grafana

Once Grafana is running:

1. Log in to Grafana
2. Go to **Configuration → Data Sources**
3. Add Prometheus with URL: `http://prometheus-operated.monitoring.svc`
4. Import dashboard IDs from https://grafana.com/grafana/dashboards

---

## 🎉 Done!

You now have full monitoring set up on EKS with Prometheus, Grafana, and optional email alerting!
