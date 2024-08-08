
pipeline{
    agent any
    stages{
        stage('Git Checkout'){
            steps{
                git poll: true, branch: 'main', url: 'https://github.com/DevopsFarmer/todo.git'
            }
        }
        
        stage('Build Application with Docker'){
            steps{
                sh 'ls -al'
                echo "Building the TODO Application....."
                sh "docker build -t todo_app ."
            }
        }
        
        stage('Push to Docker Hub'){
            steps{
                echo "Pushing TODO Application to Dockerhub....."
                withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUsername')]) {
                    sh "docker login -u devopsfarm -p ${env.dockerHubPassword}"
                    sh "docker tag todo_app devopsfarm/todo:${BUILD_TAG}"
                    sh "docker push devopsfarm/todo:${BUILD_TAG}"
                }
            }
            
        }
        
        stage('Deploy TODO Application')
        {
            when {
                expression {params.Run_Deploy_Stage}
            }
            steps{
                echo "Deploying TODO Application....."
                sh "IMAGE_NAME=devopsfarm/todo IMAGE_TAG=BUILD_TAG docker compose up -d"
            }
        }
    }
}
