# Jenkins CI/CD Pipeline with Shared Library

## Overview

This part of project implements a Jenkins CI/CD pipeline using a declarative `Jenkinsfile` and a custom Jenkins Shared Library. It automates Docker image building, vulnerability scanning, pushing to AWS ECR, and updating deployment manifests for Kubernetes via ArgoCD.

<img width="763" height="71" alt="image" src="https://github.com/user-attachments/assets/84d8a00d-ad6c-4070-9a01-4b1c94f34566" />

---

## Folder Structure

```
jenkins/
├── Jenkinsfile
└── shared_library/
    └── vars/
        ├── BuildDockerImage.groovy
        ├── ScanDockerImage.groovy
        ├── LoginToEcr.groovy
        ├── CreateEcrRepo.groovy
        ├── TagAndPushImage.groovy
        ├── CleanupLocalImages.groovy
        ├── CloneArgoRepo.groovy
        └── UpdateDeploymentFile.groovy
```
---

## Pre-requisites

* Jenkins installed with:

  * Pipeline Plugin
  * Docker installed on Jenkins agent
  * AWS credentials configured
  * Git and GitHub access
  * AWS CLI configured with access to ECR
---

## Setup Instructions

### 1. Configure Shared Library in Jenkins

* Go to **Manage Jenkins > Configure System > Global Pipeline Libraries**
* Add:

  * Name: `cloud_devops_project`
  * Default Version: `main` (or branch name)
  * Retrieval method: Modern SCM
  * SCM: Git
  * Project Repository: (your GitHub repo URL with shared library)

## 2. Jenkins Credentials Configuration

Go to **Manage Jenkins > Credentials > System > Global credentials** then Click **Add Credentials**
Ensure the following credentials are created in Jenkins:

a. **AWS Credentials (Access Key + Secret Key + Session Token)**

   * Kind: `Secret text`
   * ID: `aws-access-key` , `aws-secret-key` , `aws-session-token`

b. **GitHub Credentials (for private repo access if needed)**

   * Kind: `Username with password`
   * ID: `github`

c. **SSH Credentials (to connect with jenkins-slave)**

   * Kind: `SSH Username with private key`
   * ID: `agent`

> Use these credential IDs in your Jenkinsfile and shared library scripts to access secure resources.

## 3. Jenkins Agent Setup

To execute CI/CD pipeline stages, Jenkins must have at least one functional build agent (node). Here's how to configure it:

### a. Create a New Node in Jenkins

* Go to **Manage Jenkins > Manage Nodes and Clouds > New Node**
* Name: `agent-vm`
* Type: Permanent Agent
* Configure:

  * # of executors: 1 or more
  * Remote root directory: `/home/jenkins_home`
  * Launch method: Launch agent via SSH
  * Host: `<IP or hostname>`
  * Credentials: Add SSH private key credentials for login

### b. Test the Connection

* Click **Save** and then test the connection to ensure the agent is online.
  
---


### 4. Create a Jenkins Pipeline Job

* New Item → Pipeline → Configure
* Definition: Pipeline script from SCM
* SCM: Git → insert your repo URL
* Script Path: `jenkins/Jenkinsfile`

## 🧱 Jenkinsfile Explanation

```groovy
pipeline {
    agent any
    environment {
       AWS_REGION = 'us-east-1'
       ECR_REPO = 'nodejs_app'
       ECR_REGISTRY = '289222951012.dkr.ecr.us-east-1.amazonaws.com'
       IMAGE_TAG = "${BUILD_NUMBER}"
       GIT_CREDENTIALS_ID = 'github'
       CLUSTER_NAME = 'my-eks-cluster'
       NAMESPACE = 'ivolve'
       DEPLOYMENT_FILE = 'deployment.yml'
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    BuildDockerImage()
                }
            }
        }
        stage('Scan Image') {
            steps {
                script {
                    ScanDockerImage()
                }
            }
        }
        stage('Login to ECR') {
            steps {
                script {
                    LoginToEcr()
                }
            }
        }
        stage('Create ECR Repo') {
            steps {
                script {
                    CreateEcrRepo()
                }
            }
        }
        stage('Tag & Push Image') {
            steps {
                script {
                    TagAndPushImage()
                }
            }
        }
        stage('Cleanup Images') {
            steps {
                script {
                    CleanupLocalImages()
                }
            }
        }
        stage('Clone Argo Repo') {
            steps {
                script {
                    CloneArgoRepo()
                }
            }
        }
        stage('Update Deployment File') {
            steps {
                script {
                    UpdateDeploymentFile()
                }
            }
        }
    }
}
```

## 📚 Shared Library Functions

Each Groovy file under `vars/` corresponds to a custom step:

* **BuildDockerImage.groovy**: Builds the Docker image.
* **ScanDockerImage.groovy**: Scans the image using tools like Trivy.
* **LoginToEcr.groovy**: Authenticates Docker to AWS ECR.
* **CreateEcrRepo.groovy**: Creates ECR repo if not exists.
* **TagAndPushImage.groovy**: Tags and pushes the image to ECR.
* **CloneArgoRepo.groovy**: Clones the GitOps repo used by ArgoCD.
* **UpdateDeploymentFile.groovy**: Updates the image tag in Kubernetes manifest.
* **CleanupLocalImages.groovy**: Removes local Docker images to free space.

## 🚀 Usage

1. Commit the Jenkinsfile and shared library to GitHub.
2. Trigger the Jenkins job manually or via webhook.
3. Monitor each stage execution in Jenkins.
4. Confirm the updated deployment in ArgoCD.

---

## 🛠 Example

After pushing to GitHub, the pipeline will:

* Build and scan the Docker image.
* Push it to AWS ECR.
* Clone the Argo repo and update the manifest.
* ArgoCD will detect the change and deploy it.

## 🙌 Credits

Developed as part of a CI/CD learning lab with Jenkins Shared Libraries.

## 📄 License

MIT License or internal use (update based on your use case).
