def call() {
  dir('argocd_k8s_manifest/nodejs_app_deployment') {
    withCredentials([usernamePassword(credentialsId: GIT_CREDENTIALS_ID, usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
      sh '''
        git config user.name "jenkins"
        git config user.email "jenkins@example.com"
        git stash
        git pull origin main --rebase
        git stash pop || true

        sed -i 's|image:.*|image: '"$ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG"'|' $DEPLOYMENT_FILE
        git add $DEPLOYMENT_FILE
        git commit -m "Update image to $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG" || echo "No changes to commit"

        git push https://$GIT_USERNAME:$GIT_PASSWORD@github.com/Orabi20/CloudDevOpsProject.git
      '''
    }
  }
}
