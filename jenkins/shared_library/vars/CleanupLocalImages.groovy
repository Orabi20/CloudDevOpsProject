def call() {
  sh '''
    docker rmi $ECR_REPO:$IMAGE_TAG || true
    docker rmi $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG || true
  '''
}
