@Library('ios-libs') _
pipeline {
  agent { label "ios" }

  environment {
    MATCH_GIT_URL="$CODE_REPO_SSH_URL/ios-code-signing.git"

    APP_STORE_CONNECT_API_KEY_KEY_ID = credentials('appstore-connect-api-key-id')
    APP_STORE_CONNECT_API_KEY_ISSUER_ID = credentials('appstore-connect-api-issuer-id')
    APP_STORE_CONNECT_API_KEY_KEY = credentials('appstore-connect-api-key-content-base64')
    APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64 = true
  }

  stages {
    stage('Get TestFlight Notes') {
      when {
        anyOf {
          branch 'master'; branch 'release/*'; branch 'hotfix/*'
        }
      }

      steps {
        echo "Prompting user to enter TestFlight notes..."
        script {
            try {
                timeout(time:60, unit:'SECONDS') {
                  TESTFLIGHT_NOTES = input(
                        message: 'Please enter TestFlight notes',
                        parameters: [
                                [$class: 'TextParameterDefinition',
                                 defaultValue: 'No test notes from developer.',
                                 description: 'These notes can help the QA to know what to test in this build. It will be great if the issue number is mentioned as well.', name: 'Enter the notes (or leave default) and press [Proceed]:']
                        ]
                  )
                  echo ("Test notes entered by the user: " + TESTFLIGHT_NOTES)
                  env.TESTFLIGHT_NOTES = TESTFLIGHT_NOTES
                }
            } catch(err) {
                echo ("Timeout reached or input aborted. Default test notes shall be used in TestFlight.")
                env.TESTFLIGHT_NOTES = "No test notes from developer."
            }
        }
      }
    }

    stage('Tests') {
      steps {
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

    stage('Build'){
      when {
        anyOf {
          branch 'master'; branch 'release/*'; branch 'hotfix/*'
        }
      }

      steps {
        sh './bundle-db.sh'
        buildApp()
      }
    }

    stage('Deploy to TestFlight') {
      when {
        anyOf {
          branch 'master'; branch 'release/*'; branch 'hotfix/*'
        }
      }

      steps {
        deploy deployLane: "deploy_testflight"
      }
    }

  }
}
