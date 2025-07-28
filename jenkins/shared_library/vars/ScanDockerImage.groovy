def call() {
  sh 'trivy image --format json --output trivy-report.json $ECR_REPO:$IMAGE_TAG'
}
