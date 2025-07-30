# 📊 Monitoring EKS with Prometheus & Grafana

This guide explains how to install and configure Prometheus and Grafana on your Amazon EKS cluster using Helm charts.

<img width="796" height="335" alt="image" src="https://github.com/user-attachments/assets/d845ce1f-66b7-4e84-98cd-85f7c46229c6" />


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

### Add EC2 targets to Prometheus config

Update your Prometheus `ScrapeConfigs` section:

```sh
kubectl edit configmap prometheus-server -n monitoring
```
```yaml
  scrape_configs:

    - job_name: 'jenkins-master-node'
      static_configs:
      - targets: ['3.221.163.197:9100']

    - job_name: 'jenkins-slave-node'
      static_configs:
      - targets: ['35.171.161.72:9100']

    - job_name: 'jenkins'
      metrics_path: '/prometheus'
      static_configs:
      - targets: ['3.221.163.197:8080']
```
<img width="958" height="448" alt="image" src="https://github.com/user-attachments/assets/1baebfa3-8caf-4ae9-911c-43474adbf910" />


---

## Install Grafana

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
4. Import dashboard IDs :
   -  Jenkins Dashboard       : 9964
   -  EKS Dashboard           : 315
   -  Node Exporter Dashboard : 1860

---

## Email Notification Setup in Grafana

1. Create Grafana config (`grafana.ini`) :

```ini
[smtp]
enabled = true
host = smtp.gmail.com:587
user = your-email@gmail.com
password = your-app-password
from_address = your-email@gmail.com
from_name = Grafana
skip_verify = true
```

2. Apply `grafana.ini`:

```bash
kubectl create configmap grafana --from-file=grafana.ini=grafana.ini -n monitoring

```
```bash
kubectl patch deployment grafana -n monitoring --type merge -p '{
  "spec": {
    "template": {
      "spec": {
        "volumes": [
          {
            "name": "grafana-config",
            "configMap": {
              "name": "grafana"
            }
          }
        ],
        "containers": [
          {
            "name": "grafana",
            "image": "grafana/grafana:latest",
            "volumeMounts": [
              {
                "name": "grafana-config",
                "mountPath": "/etc/grafana/grafana.ini",
                "subPath": "grafana.ini"
              }
            ]
          }
        ]
      }
    }
  }
}'
```
```bash
kubectl rollout restart deployment grafana -n monitoring
```

---

## 5. Add Email Contact Point in Grafana

1. Open Grafana UI → Alerting → **Contact Points**
2. Click `New contact point`
3. Name: `email-notify`
4. Type: `Email`
5. Enter destination email address
6. Save

---

## 6. Create Alert Rule

1. Go to **Alerting → Alert Rules**
2. Click `New alert rule`
3. Name: `Jenkins Failure Alert`
4. Add query:

```promql
increase(default_jenkins_builds_failed_build_count_total{jenkins_job="Cloud Devops Project"}[5m]) > 0
```

5. Set condition:
   - Expression: `IS ABOVE`
   - Threshold: `0`

6. Add labels and annotations:
   ```yaml
   Labels:
     severity: critical

   Annotations:
     summary: "Jenkins Job Failed"
     description: "Job {{ $labels.jenkins_job }} has failed in the last 5 minutes."
   ```

7. Add to **Group Name** (e.g., `jenkins-alerts`)
8. Link to **Contact Point**: `email-notify`
9. Click **Save and Exit**

---

## 7. Test

Trigger a failing Jenkins job and verify:

- Metric updates in Prometheus
- Alert triggers in Grafana
- Email notification received

---

## Notes on Gmail SMTP

If using Gmail, create an **App Password**:

1. Enable 2FA on your Google account
2. Go to: https://myaccount.google.com/apppasswords
3. Create a password for “Mail” → Use this as your SMTP `password`
