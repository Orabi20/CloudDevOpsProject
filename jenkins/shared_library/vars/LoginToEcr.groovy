def call() {
  withCredentials([
    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY'),
    string(credentialsId: 'aws-session-token', variable: 'AWS_SESSION_TOKEN')
  ]) {
    sh '''
      aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
      aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
      aws configure set aws_session_token $AWS_SESSION_TOKEN
      aws configure set region $AWS_REGION

      aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
    '''
  }
}
