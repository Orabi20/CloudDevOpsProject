# 📘 Ansible Automation Setup

This project contains an Ansible-based automation for provisioning and configuring a CI/CD environment on AWS EC2 instances. It includes roles for installing Jenkins (Master/Slave), Docker, Git, Java, Trivy, AWS CLI, and Node Exporter.

---

## 📁 Project Structure

```
ansible/
├── ansible.cfg
├── aws_ec2.yaml               # Playbook for provisioning AWS EC2 instances
├── jenkins_slave.yaml         # Playbook to configure Jenkins slave
├── playbook.yaml              # Main playbook to run all roles
└── roles/
    ├── aws_cli/
    ├── common/
    ├── docker/
    ├── git/
    ├── java/
    ├── jenkins_master/
    ├── node_exporter/
    └── trivy/
```

---

## 🚀 Getting Started

### 1. Prerequisites

Ensure you have the following installed on your control machine:

- Python 3.x
- Ansible
- AWS CLI (configured with access keys)
- boto3 (`pip install boto3`)

### 2. Setup

Clone the repository or unzip the project:

```bash
cd ansible
```

---

## ⚙️ Configuration

### `ansible.cfg`

Sets Ansible config:

```ini
[defaults]
inventory = ./inventory
host_key_checking = False
```

You should create an `inventory` file or use dynamic inventory for AWS.

---

## 📜 Playbooks Overview

### 1. `aws_ec2.yaml` – Provision EC2 Instances

```yaml
- name: Launch EC2 Instance
  hosts: localhost
  connection: local
  gather_facts: False
  tasks:
    - name: Launch EC2 instance
      ec2:
        key_name: your-key
        instance_type: t2.micro
        image: ami-12345678
        wait: yes
        region: us-east-1
        count: 1
        instance_tags:
          Name: JenkinsServer
        vpc_subnet_id: subnet-xxxxxx
        assign_public_ip: yes
```

### 2. `playbook.yaml` – Install Tools on EC2

```yaml
- name: Install DevOps Tools
  hosts: all
  become: yes
  roles:
    - common
    - aws_cli
    - docker
    - git
    - java
    - jenkins_master
    - trivy
    - node_exporter
```

### 3. `jenkins_slave.yaml` – Configure Jenkins Slave

```yaml
- name: Setup Jenkins Slave Node
  hosts: slave
  become: yes
  roles:
    - java
    - docker
    - node_exporter
```

---

## 📦 Role Descriptions

Each role includes a `tasks/main.yaml`. Here's an example:

### 🔧 `roles/docker/tasks/main.yaml`

```yaml
- name: Install Docker
  apt:
    name: docker.io
    state: present
    update_cache: yes

- name: Start and enable Docker
  systemd:
    name: docker
    state: started
    enabled: yes
```

### 🔧 `roles/jenkins_master/tasks/main.yaml`

```yaml
- name: Add Jenkins key and repo
  apt_key:
    url: https://pkg.jenkins.io/debian/jenkins.io.key
    state: present

- name: Install Jenkins
  apt:
    name: jenkins
    state: present
    update_cache: yes

- name: Start and enable Jenkins
  systemd:
    name: jenkins
    state: started
    enabled: yes
```

_Similar structures exist for all other roles._

---

## 🧪 Run Playbooks

### 1. Provision EC2 Instance

```bash
ansible-playbook aws_ec2.yaml
```

### 2. Configure Jenkins Master

```bash
ansible-playbook -i inventory playbook.yaml
```

### 3. Configure Jenkins Slave

```bash
ansible-playbook -i inventory jenkins_slave.yaml
```

---

## 🔐 Security Notes

- Ensure your AWS credentials are managed securely (e.g., via environment variables or vault).
- Secure SSH keys and restrict security groups as needed.

---

## 📚 Notes

- `inventory` file or dynamic inventory plugin is required for targeting EC2 instances.
- Use tags for better playbook targeting.
