@Library('ios-libs') _
pipeline {
  agent { label "ios" }
    
  stages {
    stage('Unit Tests') {
      steps {
        runUnitTests()
      }
      
      post {
        always {
		  fastlane("clean_simulator")
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
}
