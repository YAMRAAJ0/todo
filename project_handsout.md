# CAPSTONE PROJECT
This project demonstrate how to make CICD setup for a node js application

* Tips:
    * use github codespace whereever possible when you need a linux shell and code editor. This saves you a lot of time and resources that otherwise you will waste in system setup.
    * Install terraform using 
        ```bash
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

        gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint

        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list

        sudo apt update
        sudo apt-get install terraform
        ```
    * Installing AWS cli
        ```bash
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        ```
## First steps 
1. Clone/Fork the github repo https://github.com/LalitJ-All-Info/todo
2. Create terraform IAM role so that terraform can create aws resource on your account. Create credentials and save the file on local
3. Create s3 bucket for terraform state file named terraform `<ypurname>-tfstate-terraform-101`. this needs to be updated in [backend.tf](./terraform/ec2instance/backend.tf) file as well
4. Create EC2 AWS instance using terraform [ec2instance tf code](./terraform/ec2instance)
> Note: You can use terraform code to create EC2 instance or do it manually
```
cd terraform/ec2instance
aws configure
# promts from aws configure 
# enter you aws crentials generated in step 2
terraform init
terraform plan
terraform apply
```

5. Once you run the terraform code you will get ssh_connect_strings and jenkins_url as terraform output.
6. run below command to get jenkins admin password
 ```bash
 ssh_connect_string  "cat /var/lib/jenkins/secrets/initialAdminPassword"
 ```
7. Login to jenkins and do initial setup. Once all done. change admin password to admin. and try to login again.
8. After Installing All The requirements Go to Jenkins and create a new pipeline job and write below code in Groovy syntax for Git Checkout, Build Application with Docker, Push to Docker Hub, Deploy TODO Application

    ```groovy
    pipeline{
        stages{
            stage('Git Checkout'){
                steps{
                    git branch: 'main', url: 'https://github.com/LalitJ-All-Info/todo.git'
                }
            }
            
            stage('Build Application with Docker'){
                steps{
                    echo "Building the TODO Application....."
                    sh "docker build -t todo_app ."
                }
            }
            
            stage('Push to Docker Hub'){
                steps{
                    echo "Pushing TODO Application to Dockerhub....."
                    withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUsername')]) {
                        sh "docker login -u ${env.dockerHubUsername} -p ${env.dockerHubPassword}"
                        sh "docker tag todo_app ${env.dockerHubUsername}/todo:${BUILD_TAG}"
                        sh "docker push ${env.dockerHubUsername}/todo:${BUILD_TAG}"
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
                    sh "docker run -d --name todo -p 3000:3000 ${env.dockerHubUsername}/todo:${BUILD_TAG}"
                }
            }
        }
    }

    ```

9. Create jenkins credential "dockerHub" that is used in our pipeline script. Usename password for you dockerhub account. (if you don't have one, You need to signup for the same)
