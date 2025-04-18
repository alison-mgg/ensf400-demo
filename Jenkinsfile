pipeline {
    agent any

    environment {
        
        // Other environment variables if needed
        HTTP_PROXY = 'http://127.0.0.1:9888'
        SONAR_TOKEN = credentials('ENSF400-DEMO')
        SONARQUBE_URL = 'http://sonarqube:9000'  
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Verify Java Version') {
            steps {
                sh 'java -version'
            }
        }
        
        stage('Build') {
            steps {
                sh './gradlew clean assemble'
            }
        }
        
        
       stage('Unit Tests') {
   steps {
       // no need to change directory, gradlew is in the root folder
       sh './gradlew test'
   }
   post {
     always {
       // no need to change directory, gradlew is in the root folder
       junit 'build/test-results/test/*.xml'
     }
   }
}

        
        stage('Database Tests') {
            steps {
                // Execute tests that require a database connection.
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
                // Generate BDD reports and Jacoco code coverage reports.
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
         sh './gradlew sonarqube -Dsonar.host.url=$SONARQUBE_URL -Dsonar.login=$SONAR_TOKEN'
        sleep 5
        sh './gradlew checkQualityGate'
    }
}

        
      stage('Deploy to Test') {
    steps {
        // Deploy to a test environment using Gradle.
        sh './gradlew deployToTestWindowsLocal'

        // Install pipenv (ensure pip is available)
        sh 'pip install --user pipenv'

        // Add pipenv path to PATH if needed
        sh 'export PATH=$PATH:$HOME/.local/bin && PIPENV_IGNORE_VIRTUALENVS=1 pipenv install'

        // Wait for the deployed service to become available.
        sh './gradlew waitForHeartBeat'

        // Clear any previous Zap sessions.
        sh 'curl http://zap/JSON/core/action/newSession -s --proxy localhost:9888'
    }
}

        
        stage('API Tests') {
            steps {
                // Run API tests.
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
                // Run UI Behavior Driven tests and generate reports.
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
                // Run Java-based UI tests; adjust the directory if needed.
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
                // Check for vulnerable dependencies.
                sh './gradlew dependencyCheckAnalyze'
            }
        }
        
        stage('Performance Tests') {
            steps {
                // Run performance tests with JMeter or another tool.
                sh './gradlew runPerfTests'
            }
        }
        
        stage('Mutation Tests') {
            steps {
                // Run mutation tests (e.g., using PIT).
                sh './gradlew pitest'
            }
        }
        
        stage('Build Documentation') {
            steps {
                // Generate project documentation (e.g., Javadoc).
                sh './gradlew javadoc'
            }
        }
        
        stage('Collect Zap Security Report') {
            steps {
                // Create report directory and collect the OWASP Zap report.
                sh 'mkdir -p build/reports/zap'
                sh 'curl http://zap/OTHER/core/other/htmlreport --proxy localhost:9888 > build/reports/zap/zap_report.html'
            }
        }
        
        stage('Deploy to Prod') {
            steps {
                // Simulate deployment to production.
                sh 'sleep 5'
            }
        }
    }
    
    // Optional: post-build actions
    post {
        always {
            // Clean up or archive artifacts after every build if needed.
            echo 'Pipeline finished.'
        }
    }
}
