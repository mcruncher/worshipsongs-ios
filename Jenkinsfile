@Library('ios-libs') _
pipeline {
  agent { label "ios" }
    
  stages {
    stage('Unit Tests') {
      steps {
        notifyBuildStatus 'STARTED'
        runUnitTests()
      }
      
      post {
        always {
          terminateSimulator()
          archiveUnitTestsReport()
        }
      }
    }
    
    stage('Code Analysis') {
      steps {
        runCodeAnalysis branchName: "$BRANCH_NAME"
      }
    }
    
  }
  
  post {
    always {
      notifyBuildStatus currentBuild.result
    }
  }
}
