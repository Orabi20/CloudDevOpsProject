#  Ansible Automation Setup

This part of project contains an Ansible-based automation for provisioning and configuring a CI/CD environment on AWS EC2 instances. It includes roles for installing Jenkins (Master/Slave), Docker, Git, Java, Trivy, AWS CLI, and Node Exporter.

<img width="380" height="368" alt="image" src="https://github.com/user-attachments/assets/2cb505a5-e499-4f2f-a3aa-a187540564c5" />

---

## Project Structure

```
ansible/
├── ansible.cfg
├── aws_ec2.yaml               # Playbook for dynamic provisioning AWS EC2 instances
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

## Getting Started

### Prerequisites

Ensure you have the following installed on your control machine:

- Python 3.x
- Ansible
- AWS CLI (configured with access keys)
- boto3 (`pip install boto3`)

---
## Configuration

### `ansible.cfg`

Sets Ansible config:

```ini
[defaults]
host_key_checking = False
remote_user = ec2-user
```

---

## Playbooks Overview

### 1. `aws_ec2.yaml` – Provision EC2 Instances

```yaml
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  tag:Name:
    - jenkins-master
    - jenkins-slave
keyed_groups:
  - key: tags.Name
    prefix: tag
hostnames:
  - ip-address
vars:
  ansible_ssh_private_key_file: /home/orabi/.ssh/eks-keypair
```
<img width="946" height="150" alt="image" src="https://github.com/user-attachments/assets/9dc031ac-01bc-40f7-8e30-e086cb33943a" />

### 2. `playbook.yaml` – Install Tools on EC2 instences

```yaml
---
- name: Setup Jenkins Master
  hosts: tag_jenkins_master
  become: true
  roles:
    - aws_cli
    - common
    - git
    - docker
    - java
    - jenkins_master
    - node_exporter

- name: Setup Jenkins Slave
  hosts: tag_jenkins_slave
  become: true
  roles:
    - trivy
    - aws_cli
    - common
    - git
    - docker
    - java
    - node_exporter

```

### 3. `jenkins_slave.yaml` – Configure Jenkins Slave

```yaml
---
- name: Copy SSH keys to Jenkins Master
  hosts: tag_jenkins_master
  become: yes
  vars:
    ssh_key_local_path: ~/.ssh/eks-keypair
    ssh_key_dest: /home/ec2-user/.ssh/jenkins_agent_key
    ssh_user: ec2-user

  tasks:
    - name: Ensure .ssh directory exists on master
      file:
        path: /home/{{ ssh_user }}/.ssh
        state: directory
        owner: "{{ ssh_user }}"
        group: "{{ ssh_user }}"
        mode: '0700'

    - name: Copy private key to master
      copy:
        src: "{{ ssh_key_local_path }}"
        dest: "{{ ssh_key_dest }}"
        owner: "{{ ssh_user }}"
        group: "{{ ssh_user }}"
        mode: '0600'

    - name: Copy public key to master
      copy:
        src: "{{ ssh_key_local_path }}.pub"
        dest: "{{ ssh_key_dest }}.pub"
        owner: "{{ ssh_user }}"
        group: "{{ ssh_user }}"
        mode: '0644'

    - name: Send public key from master to slave
      delegate_to: "{{ inventory_hostname }}"
      become_user: "{{ ssh_user }}"
      shell: |
        ssh -o StrictHostKeyChecking=no -i {{ ssh_key_dest }} {{ ssh_user }}@{{ groups['tag_jenkins_slave'][0] }} \
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '{{ lookup('file', ssh_key_local_path + '.pub') }}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

- name: Create Jenkins home on Slave
  hosts: tag_jenkins_slave
  become: yes
  tasks:
    - name: Create /home/jenkins_home directory
      file:
        path: /home/jenkins_home
        state: directory
        mode: '0777'

```

---

## Run Playbooks

### 1. Install Tools on EC2 instences

```bash
ansible-playbook -i aws_ec2.yaml playbook.yaml
```
<img width="949" height="52" alt="image" src="https://github.com/user-attachments/assets/eb6996a6-4352-450e-951c-528da8340f59" />

### 2. Configure Jenkins Slave

```bash
ansible-playbook -i inventory jenkins_slave.yaml
```
<img width="952" height="54" alt="image" src="https://github.com/user-attachments/assets/2ab97398-1e74-4cb2-afb5-f03f14f630ec" />

---

