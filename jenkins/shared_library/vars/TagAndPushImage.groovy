def call() {
  sh '''
    docker tag $ECR_REPO:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
    docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
  '''
}
