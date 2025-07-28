
# Terraform AWS Infrastructure Deployment

This part of project uses **Terraform** to provision a complete infrastructure on **AWS**, including networking, EC2 servers, and an EKS (Elastic Kubernetes Service) cluster. also uses **remote state management** via `backend.tf`.

                                                 <img width="382" height="365" alt="image" src="https://github.com/user-attachments/assets/9783cda2-35ee-49cb-a0ad-03c5ae79512b" />
                                                          
---

## Directory Structure

```
terraform/
├── backend.tf          # Remote backend config (e.g., S3 + DynamoDB)
├── eks.tf              # EKS cluster configuration
├── network.tf          # VPC, Subnets, IGW, Route Tables
├── outputs.tf          # Terraform output values
├── server.tf           # EC2 instance or server config
├── terraform.tfvars    # Variable values (user-defined)
├── variables.tf        # Variable definitions
```

---

## Prerequisites

- Terraform CLI >= 1.0  
- AWS CLI configured with `aws configure`  
- An AWS IAM user with programmatic access and admin-level permissions  
- S3 bucket and DynamoDB table for backend remote state (defined in `backend.tf`)

---

## Backend Configuration

Create an S3 bucket and DynamoDB table for remote state:

```bash
aws s3api create-bucket --bucket <your-bucket-name> --region <your-region>

aws dynamodb create-table \
  --table-name <your-lock-table> \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Then update `backend.tf` accordingly:

```hcl
terraform {
  backend "s3" {
    bucket         = "<your-bucket-name>"
    key            = "terraform.tfstate"
    region         = "<your-region>"
    dynamodb_table = "<your-lock-table>"
    encrypt        = true
  }
}
```

---

## How to Use

### 1. Initialize Terraform

```bash
terraform init
```

---

### 2. Plan the Deployment

```bash
terraform plan
```
<img width="950" height="132" alt="image" src="https://github.com/user-attachments/assets/187c1fd9-b68e-4b70-8db7-c504aa1c5fb8" />

---

### 3. Apply the Configuration

```bash
terraform apply
```
<img width="947" height="30" alt="image" src="https://github.com/user-attachments/assets/a2d80fad-6535-406b-989a-26d5d2ad0e8c" />

---

### 4. Destroy the Infrastructure (Optional)

```bash
terraform destroy
```

---

## Highlights

- **Modular Design**: Resources organized by category (network, EKS, EC2).
- **Variables**: Centralized in `variables.tf` and `terraform.tfvars`.
- **Remote State**: Managed in S3 with DynamoDB locking.

---
