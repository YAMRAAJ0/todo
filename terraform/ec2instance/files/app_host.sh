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


# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl restart docker