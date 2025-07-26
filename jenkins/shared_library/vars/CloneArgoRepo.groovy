def call() {
  dir('.') {
    git branch: 'main',
        credentialsId: GIT_CREDENTIALS_ID,
        url: 'https://github.com/Orabi20/CloudDevOpsProject'
  }
}
