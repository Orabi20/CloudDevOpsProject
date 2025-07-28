# Jenkins CI/CD Pipeline with Shared Library

## 📘 Overview

This project implements a Jenkins CI/CD pipeline using a declarative `Jenkinsfile` and a custom Jenkins Shared Library. It automates Docker image building, vulnerability scanning, pushing to AWS ECR, and updating deployment manifests for Kubernetes via ArgoCD.

## 🗂 Folder Structure

```
jenkins/
├── Jenkinsfile
└── shared_library/
    └── vars/
        ├── BuildDockerImage.groovy
        ├── CleanupLocalImages.groovy
        ├── CloneArgoRepo.groovy
        ├── CreateEcrRepo.groovy
        ├── LoginToEcr.groovy
        ├── ScanDockerImage.groovy
        ├── TagAndPushImage.groovy
        └── UpdateDeploymentFile.groovy
```

## ✅ Pre-requisites

* Jenkins installed with:

  * Pipeline Plugin
  * Docker installed on Jenkins agent
  * AWS credentials configured
  * Git and GitHub access
* AWS CLI configured with access to ECR
* ArgoCD setup and integrated with Kubernetes

## ⚙️ Setup Instructions

### 1. Configure Shared Library in Jenkins

* Go to **Manage Jenkins > Configure System > Global Pipeline Libraries**
* Add:

  * Name: `shared_library`
  * Default Version: `master` (or branch name)
  * Retrieval method: Modern SCM
  * SCM: Git
  * Project Repository: (your GitHub repo URL with shared library)

### 2. Create a Jenkins Pipeline Job

* New Item → Pipeline → Configure
* Definition: Pipeline script from SCM
* SCM: Git → insert your repo URL
* Script Path: `jenkins/Jenkinsfile`

## 🧱 Jenkinsfile Explanation

```groovy
pipeline {
    agent any
    environment {
        IMAGE_NAME = "your-app"
        IMAGE_TAG = "latest"
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        REGION = 'us-east-1'
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
        stage('Cleanup Images') {
            steps {
                script {
                    CleanupLocalImages()
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
