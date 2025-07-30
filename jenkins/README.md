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
 
  <img width="782" height="252" alt="image" src="https://github.com/user-attachments/assets/acc1151b-7d4a-442d-a073-2ce84b105017" />

---


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


<img width="945" height="347" alt="image" src="https://github.com/user-attachments/assets/7e4c1e11-3c5d-4f27-9396-546d94273a87" />

---


## 3. Jenkins Agent Setup

To execute CI/CD pipeline stages, Jenkins must have at least one functional build agent (node). Here's how to configure it:

### a. Create a New Node in Jenkins

* Go to **Manage Jenkins > Manage Nodes and Clouds > New Node**
* Name: `agent-vm`
* Type: Permanent Agent
* Configure:

  * of executors: 1 or more
  * Remote root directory: `/home/jenkins_home`
  * Launch method: Launch agent via SSH
  * Host: `<IP or hostname>`
  * Credentials: Add SSH private key credentials for login

### b. Test the Connection

* Click **Save** and then test the connection to ensure the agent is online.

 <img width="929" height="278" alt="image" src="https://github.com/user-attachments/assets/c99d57c9-edcb-4ac9-87a2-100d0f58eb78" />

  
---


### 4. Create a Jenkins Pipeline Job

* New Item → Pipeline → Configure
* Definition: Pipeline script from SCM
* SCM: Git → insert your repo URL
* Script Path: `jenkins/Jenkinsfile`

## a. Jenkinsfile Explanation

```groovy
@Library('cloud_devops_project') _

pipeline {
  agent { label 'agent-vm' }

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
      steps { BuildDockerImage() }
    }

    stage('Scan Docker Image Using Trivy') {
      steps { ScanDockerImage() }
    }

    stage('Login to AWS ECR') {
      steps { LoginToEcr() }
    }

    stage('Create ECR Repo if Not Exists') {
      steps { CreateEcrRepo() }
    }

    stage('Tag & Push Docker Image to ECR') {
      steps { TagAndPushImage() }
    }

    stage('Cleanup Local Images') {
      steps { CleanupLocalImages() }
    }

    stage('Clone ArgoCD Manifests Repo') {
      steps { CloneArgoRepo() }
    }

    stage('Update Deployment File with New Image') {
      steps { UpdateDeploymentFile() }
    }
  }

  post {
    success { echo 'Deployment successful' }
    failure { echo 'Deployment failed' }
  }
}
```

## b. Shared Library Functions

Each Groovy file under `vars/` corresponds to a custom step:

* **BuildDockerImage.groovy**: Builds the Docker image.

  <img width="328" height="34" alt="image" src="https://github.com/user-attachments/assets/8cec5413-b0c3-46cb-89f6-a2d705476da3" />

  
* **ScanDockerImage.groovy**: Scans the image using tools like Trivy.

  <img width="389" height="50" alt="image" src="https://github.com/user-attachments/assets/0abe80c2-1d03-4450-8612-ce7209b61fb3" />

  
* **LoginToEcr.groovy**: Authenticates Docker to AWS ECR.

  <img width="532" height="186" alt="image" src="https://github.com/user-attachments/assets/1a840087-e540-464a-8445-1f7f05171f28" />

  
* **CreateEcrRepo.groovy**: Creates ECR repo if not exists.

  <img width="529" height="334" alt="image" src="https://github.com/user-attachments/assets/7e327924-8944-4f93-a3df-0490b07acea9" />

  
* **TagAndPushImage.groovy**: Tags and pushes the image to ECR.

  <img width="521" height="68" alt="image" src="https://github.com/user-attachments/assets/a656026c-81aa-4f72-b7a8-60a684b65da6" />

  <img width="754" height="135" alt="image" src="https://github.com/user-attachments/assets/1f67b683-912f-4fee-a1bd-ed7db3dcf096" />



* **CleanupLocalImages.groovy**: Removes local Docker images to free space.

  <img width="579" height="155" alt="image" src="https://github.com/user-attachments/assets/6a612d9c-de36-49f9-a226-a7ca010d8a76" />

  
* **CloneArgoRepo.groovy**: Clones the GitOps repo used by ArgoCD.

  <img width="354" height="118" alt="image" src="https://github.com/user-attachments/assets/52374e0d-e40a-434b-ab98-eeab4257d2a7" />

  
* **UpdateDeploymentFile.groovy**: Updates the image tag in Kubernetes manifest.

  <img width="512" height="71" alt="image" src="https://github.com/user-attachments/assets/a932ffb7-690a-4bd6-b381-3e7785b08011" />

  


## 5. Usage

1. Commit the Jenkinsfile and shared library to GitHub.
2. Trigger the Jenkins job manually or via webhook.
3. Monitor each stage execution in Jenkins.
4. Confirm the updated deployment in ArgoCD.

   <img width="937" height="253" alt="image" src="https://github.com/user-attachments/assets/8e3d4066-5eff-4881-a1bb-040a8724f317" />


---



