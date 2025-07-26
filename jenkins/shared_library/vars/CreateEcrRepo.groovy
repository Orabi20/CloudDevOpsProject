def call() {
  sh '''
    aws ecr describe-repositories --repository-names $ECR_REPO || \
    aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION
  '''
}
