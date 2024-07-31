# CAPSTONE PROJECT
We Will do a project with todo application
Fork GitHub Repo https://github.com/LalitJ-All-Info/todo

Then, Create an Instance on AWS

Install JDK, Jenkins, and Docker in AWS instances 

To install Jenkins and JDK Follow this https://www.jenkins.io/doc/book/installing/linux/ OR

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)

sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins


Install Docker in AWS Instance Follow this https://docs.docker.com/engine/install/ubuntu/ OR

Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

Install the Docker packages.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Verify that the Docker Engine installation is successfully 
sudo service docker start


DOCKERFILE FOR TODO PROJECT
FROM node:20

WORKDIR /myapp

COPY  . . 

RUN npm install

EXPOSE 3000

CMD ["node", "index.js"]


After Installing All The requirements Go to Jenkins and create a new pipeline with the same GitHub repo that you created before and 
write code in Groovy syntax for Git Checkout, Build Application with Docker, Push to Docker Hub, Deploy TODO Application

pipeline{
    agent { label 'docker' }
    
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'main', credentialsId: 'GitHub-HTTPS-Credential', url: 'https://github.com/LalitJ-All-Info/todo.git'
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
                sh "docker rm -f todo"
                sh "docker run -d --name todo -p 3000:3000 devopsfarm/todo:${BUILD_TAG}"
            }
        }
    }
}
