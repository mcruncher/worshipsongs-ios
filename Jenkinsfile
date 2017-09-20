stage 'Unit test'
node('macmini-slave-1') {
  try {
    checkout scm
    sh "killall \"iOS Simulator\" || echo \"No matching processes belonging to you were found\""
    sh """
      cd worshipsongs
      fastlane unittest """
  } catch (ex) {
  } finally {
     sh "killall \"iOS Simulator\" || echo \"No matching processes belonging to you were found\""
     step([$class: 'JUnitResultArchiver', testResults: 'worshipsongs/fastlane/report/TEST-report.xml'])
  }
}

stage 'Code analysis'
node('macmini-slave-1') {
  try {
   checkout scm
   sh """
      cd worshipsongs
      fastlane codeanalysis """
  } catch (ex) {
  } finally{
      step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'nectar/fastlane/report/cobertura.xml', failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
  }
}
