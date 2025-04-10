pipeline {
    agent any

    tools {
        maven 'Maven 3.8.1'
    }

    environment {
        IMAGE_NAME = 'kireeti1234/myapp'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push to DockerHub') {
            when {
                anyOf {
                    branch 'main'
                    branch 'dev'
                }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                anyOf {
                    branch 'main'
                    branch 'dev'
                }
            }
            steps {
                withKubeConfig([credentialsId: 'k8s-creds']) {
                    script {
                        if (env.BRANCH_NAME == 'main') {
                            echo 'Deploying to production...'
                            sh 'kubectl apply -f k8s/production.yaml'
                        } else if (env.BRANCH_NAME == 'dev') {
                            echo 'Deploying to staging...'
                            sh 'kubectl apply -f k8s/staging.yaml'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Build and deployment completed for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Build or deployment failed for branch: ${env.BRANCH_NAME}"
        }
    }
}
