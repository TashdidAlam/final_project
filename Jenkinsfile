def imageName = "tashdidalam/spark_lms:${BUILD_ID}"
def kube_config = 'kube_config'
def git_config = 'github_ssh'

pipeline {
    agent any
    triggers{
        pollSCM('H/5 * * * *')
    }
    
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
        
        stage('Build') {
            steps {
                sh 'mvn clean install'
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
                    }
                }
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
}
