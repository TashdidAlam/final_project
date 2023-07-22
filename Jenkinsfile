def imageName = "tashdidalam/spark_lms:${BUILD_ID}"
def kube_config = 'kube_config'
def git_config = 'github_ssh'

pipeline {
    agent any

tools {
        maven "maven-3.9.3"
    }
    
    // triggers{
    //     pollSCM('H/5 * * * *')
    // }
    
    options {
  buildDiscarder logRotator(daysToKeepStr: '1', numToKeepStr: '7')
}
    
    environment {
        GIT_REPO_URL = 'git@github.com:TashdidAlam/final_project.git'
        DOCKER_REGISTRY_CREDENTIALS = 'Docker_hub'
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'route-fix', credentialsId: git_config, url: GIT_REPO_URL
            }
        }
         stage('Modify application.properties') {
            steps {
               script {
                    withCredentials([
                          string(credentialsId: 'DB_URL', variable: 'dbUrl'),
                          string(credentialsId: 'DB_USERNAME', variable: 'dbUsername'),
                          string(credentialsId: 'DB_PASSWORD', variable: 'dbPassword')
            ]) {
                sh """
                sed -i "s|spring.datasource.url =.*|spring.datasource.url = \${dbUrl}|g" /var/lib/jenkins/workspace/On_premise_deployment/src/main/resources/application.properties
                sed -i "s|spring.datasource.username =.*|spring.datasource.username = \${dbUsername}|g" /var/lib/jenkins/workspace/On_premise_deployment/src/main/resources/application.properties
                sed -i "s|spring.datasource.password =.*|spring.datasource.password = \${dbPassword}|g" /var/lib/jenkins/workspace/On_premise_deployment/src/main/resources/application.properties
                """
            }
         }
       }
      }
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONARQUBE_TOKEN')]) {
                    withSonarQubeEnv('sonarqube') {
                        script {
                            sh "mvn sonar:sonar -Dsonar.projectKey=jenkins -Dsonar.host.url=http://192.168.20.242:9000 -Dsonar.login=${SONARQUBE_TOKEN}"
                        }
                    }
                }
            }
        }
        
        stage('Docker Image Build') {
            steps {
                script {
                    img_todo = docker.build(imageName)
                }
            }
        }
        
        stage('Push to Docker Registry') {
            steps {
                script {
                    withDockerRegistry(credentialsId: DOCKER_REGISTRY_CREDENTIALS, url: '') {
                        img_todo.push()
                        img_todo.push('latest')
                    }
                }
            }
        }
        stage('Docker Image Remove') {
            steps {
                sh "docker rmi $imageName"
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kube_config', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                        def sql = sh(
                            script: 'kubectl get pod -l app=my-mysql -o name',
                            returnStatus: true
                        )
                        def web = sh(
                            script: 'kubectl get pod -l app=my-webserver -o name',
                            returnStatus: true
                        )
                        if (web == 0 || sql == 0) {
                            try {
                                sh 'kubectl delete -f app.yml'
                            } catch (Exception e) {
                                echo "Error deleting deployments: ${e.getMessage()}"
                            }
                        }
                        
                        sh 'kubectl apply -f app.yml'
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'One way or another, I have finished'
            deleteDir()
        }
        success {
            echo 'I succeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
    }
}
