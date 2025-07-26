def call() {
  dir('nodejs_app') {
    sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
  }
}
