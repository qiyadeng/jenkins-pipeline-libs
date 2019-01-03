#!/usr/bin/env groovy

/* 
 * Run the SonarQube scanner on Maven-based projects.
 *
 */


def call() {

  def sonarMvnPluginVer = '3.5.0.1254' 
  // def sonarMvnPluginVer = '3.3.0.603'

  if (env.CHANGE_ID) {
    echo "PR request: $env.CHANGE_ID"
    withCredentials([[$class: 'StringBinding', 
                      credentialsId: '6b0ebf62-3a12-4e6b-b77e-c45817b5791b', 
                      variable: 'GITHUB_ACCESS_TOKEN']]) {
      withSonarQubeEnv('SonarCloud') {
        sh "mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:${sonarMvnPluginVer}:sonar " +
                "-Dsonar.organization=folio-org -Dsonar.verbose=true " +
                "-Dsonar.pullrequest.base=master " +
                "-Dsonar.pullrequest.branch=${env.BRANCH_NAME} " +
                "-Dsonar.pullrequest.key=${env.CHANGE_ID} " +
                "-Dsonar.pullrequest.provider=github " + 
                "-Dsonar.pullrequest.github.repository=folio-org/${env.projectName} " +
                "-Dsonar.pullrequest.github.endpoint=https://api.github.com"
      }
    }  
  }
  else {  
    withSonarQubeEnv('SonarCloud') {
      if (env.BRANCH_NAME != 'master') {
        sh "mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:${sonarMvnPluginVer}:sonar " +
             "-Dsonar.organization=folio-org -Dsonar.verbose=true " +
             "-Dsonar.branch.name=${env.BRANCH_NAME} " +
             "-Dsonar.branch.target=master"
      }
      else {
        sh "mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:${sonarMvnPluginVer}:sonar " +
             "-Dsonar.organization=folio-org -Dsonar.verbose=true" 
      }
    }
  } // end 
}
