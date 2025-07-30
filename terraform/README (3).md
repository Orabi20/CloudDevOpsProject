# Terraform EKS Cluster with Jenkins CI Setup

This part of project uses **Terraform modules** to deploy:

- An **Amazon EKS cluster**
- A **custom VPC with public subnets**
- **Jenkins master/slave EC2 instances** with security groups and SSH access

<img width="382" height="365" alt="tf 3" src="https://github.com/user-attachments/assets/25f56b5f-9f35-4383-8d30-bd4a50157e8f" />

---

## Project Structure

```
.
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── modules/
    ├── eks/
    ├── network/
    └── server/
```

---

## Prerequisites

- AWS account
- AWS CLI (`aws configure`)
- Terraform CLI v1.3+ installed
- An SSH key pair in `~/.ssh/eks-keypair.pub`

---

## Setup Instructions

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Execution Plan

```bash
terraform plan
```
<img width="950" height="132" alt="tf 2" src="https://github.com/user-attachments/assets/e8506340-63c8-4fbc-a87d-acc9f252f4a9" />

### 3. Apply the Infrastructure

```bash
terraform apply
```
<img width="947" height="30" alt="tf 1" src="https://github.com/user-attachments/assets/3335ca66-79a8-4884-9c64-2026ca54695e" />

---

## Outputs

After provisioning, Terraform will output:

- VPC ID
- Subnet IDs
- EKS cluster name & endpoint
- Jenkins master & slave IPs

---

## Variables Overview

Defined in `variables.tf` and overridden via `terraform.tfvars`:

| Variable              | Description                      | Default             |
|-----------------------|----------------------------------|---------------------|
| `region`              | AWS region                       | `us-east-1`         |
| `cluster_name`        | EKS cluster name                 | `my-eks-cluster`    |
| `vpc_cidr`            | CIDR block for the VPC           | `10.0.0.0/16`       |
| `public_subnet_cidrs` | Public subnet CIDR list          | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `node_instance_type`  | EC2 type for EKS nodes           | `t3.medium`         |
| `eks_cluster_role_arn`| IAM role for EKS cluster         | [set in tfvars]     |
| `eks_node_role_arn`   | IAM role for node group          | [set in tfvars]     |

---

## Workflow Summary

1. `network/` creates:
   - `VPC`
   - `Public Subnets`
   - `Internet Gateway + Route Table`
2. `eks/` provisions:
   - EKS control plane
   - EKS managed node group
3. `server/` launches:
   - Jenkins EC2 master & slave
   - SSH key pair
   - Security group for SSH + Jenkins + metrics

---

## Module-by-Module Code Explanation

### `modules/network/` — VPC & Public Subnets

**Resources**:
- `aws_vpc`: Main VPC
- `aws_subnet`: Two subnets in different AZs
- `aws_internet_gateway`: Enables outbound internet
- `aws_route_table`: Routes `0.0.0.0/0` to IGW
- `aws_route_table_association`: Associates route table with subnets

**Outputs**:
- `vpc_id`
- `public_subnet_ids`

---

### `modules/eks/` — EKS Cluster + Worker Nodes

**Resources**:
- `aws_eks_cluster`: EKS control plane
- `aws_eks_node_group`: Managed worker nodes using IAM roles

**Inputs**:
- `eks_cluster_role_arn`
- `eks_node_role_arn`
- `subnet_ids` from network module
- `node_instance_type`

**Outputs**:
- `cluster_name`
- `cluster_endpoint`

---

### `modules/server/` — Jenkins EC2 Instances + Security

**Resources**:
- `aws_key_pair`: Uses your local `~/.ssh/eks-keypair.pub`
- `aws_security_group`: Opens ports 22 (SSH), 8080 (Jenkins), 9100 (Metrics)
- `aws_instance`: 
  - Jenkins master in subnet[0]
  - Jenkins slave in subnet[1]
- `data.aws_ami`: Selects latest Amazon Linux 2 AMI

**Outputs**:
- `jenkins_master_ip`
- `jenkins_slave_ip`

---

## Destroy Infrastructure

To remove all resources:

```bash
terraform destroy -auto-approve
```

---
