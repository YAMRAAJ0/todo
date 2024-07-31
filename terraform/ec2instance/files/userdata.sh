#!/bin/bash
apt-get update -y
apt-get upgrade -y
USERNAME=jenkins
PASSWORD=jenkins
adduser --disabled-password --gecos "" $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo $USERNAME
find /etc/ssh/sshd_config.d/ -type f -exec sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' {} +
service sshd reload


# install java
apt update
apt install fontconfig openjdk-17-jre
java -version

# install jenkins 
wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install jenkins
systemctl enable jenkins
systemctl restart jenkins


# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl restart docker