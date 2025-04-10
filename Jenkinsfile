pipeline {
  agent any

  environment {
    HTTP_PROXY = 'http://127.0.0.1:9888'
    ORG_GRADLE_JAVA_INSTALLATIONS_AUTO_DOWNLOAD = 'false'
  }

tools {
    jdk 'jdk11'
}

  stages {
    stage('Build') {
      steps {
        sh 'java -version'
        sh './gradlew clean assemble'
      }
    }

    stage('Unit Tests') {
      steps {
        sh './gradlew test'
      }
      post {
        always {
          junit 'build/test-results/test/*.xml'
        }
      }
    }

    stage('Database Tests') {
      steps {
        sh './gradlew integrate'
      }
      post {
        always {
          junit 'build/test-results/integrate/*.xml'
        }
      }
    }

    stage('BDD Tests') {
      steps {
        sh './gradlew generateCucumberReports'
        sh './gradlew jacocoTestReport'
      }
      post {
        always {
          junit 'build/test-results/bdd/*.xml'
        }
      }
    }

stage('Static Analysis') {
  steps {
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
      sh './gradlew sonarqube'
      sleep 5
      sh './gradlew checkQualityGate'
    }
  }
}

    stage('Deploy to Test') {
      steps {
        sh './gradlew deployToTestWindowsLocal'
        sh 'PIPENV_IGNORE_VIRTUALENVS=1 pipenv install'
        sh './gradlew waitForHeartBeat'
        sh 'curl http://zap/JSON/core/action/newSession -s --proxy localhost:9888'
      }
    }

    stage('API Tests') {
      steps {
        sh './gradlew runApiTests'
      }
      post {
        always {
          junit 'build/test-results/api_tests/*.xml'
        }
      }
    }

    stage('UI BDD Tests') {
      steps {
        sh './gradlew runBehaveTests'
        sh './gradlew generateCucumberReport'
      }
      post {
        always {
          junit 'build/test-results/bdd_ui/*.xml'
        }
      }
    }

    stage('UI Tests') {
      steps {
        sh 'cd src/ui_tests/java && ./gradlew clean test'
      }
      post {
        always {
          junit 'src/ui_tests/java/build/test-results/test/*.xml'
        }
      }
    }

    stage('Security: Dependency Analysis') {
      steps {
        sh './gradlew dependencyCheckAnalyze'
      }
    }

    stage('Performance Tests') {
      steps {
        sh './gradlew runPerfTests'
      }
    }

    stage('Mutation Tests') {
      steps {
        sh './gradlew pitest'
      }
    }

    stage('Build Documentation') {
      steps {
        sh './gradlew javadoc'
      }
    }

    stage('Collect Zap Security Report') {
      steps {
        sh 'mkdir -p build/reports/zap'
        sh 'curl http://zap/OTHER/core/other/htmlreport --proxy localhost:9888 > build/reports/zap/zap_report.html'
      }
    }

    stage('Deploy to Prod') {
      steps {
        sh 'sleep 5'
      }
    }
  }
}
