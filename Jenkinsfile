stage 'Unit test'
node('IMac-slave-1') {
  try {
    checkout scm
    sh "killall \"iOS Simulator\" || echo \"No matching processes belonging to you were found\""
    sh """
      cd worshipsongs
      fastlane unittest """
  } finally {
     sh "killall \"iOS Simulator\" || echo \"No matching processes belonging to you were found\""
     step([$class: 'JUnitResultArchiver', testResults: 'worshipsongs/fastlane/report/TEST-report.xml'])
  }
}

stage 'Code analysis'
node('IMac-slave-1') {
  try {
   checkout scm
   sh """
      cd worshipsongs
      fastlane codeanalysis """
  } finally{
      step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'worshipsongs/fastlane/report/cobertura.xml', failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
  }
}
