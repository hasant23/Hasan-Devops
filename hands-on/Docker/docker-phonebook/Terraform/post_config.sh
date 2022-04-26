#! /bin/bash

yum update -y 
amazon-linux-extras install docker -y 
systemctl start docker
system enable docker
systemctl status docker
usermod -a -G docker ec2-user
newgrp docker
docker version
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir phonebook-app && cd phonebook-app
FOLDER="https://raw.githubusercontent.com/hasant23/Hasan-Devops/main/hands-on/Docker/docker-phonebook"
wget ${FOLDER}/requirements.txt
wget ${FOLDER}/phonebook-app.py
wget ${FOLDER}/Dockerfile
wget ${FOLDER}/docker-compose.yml
mkdir templates && cd templates
wget  ${FOLDER}/templates/index.html
wget  ${FOLDER}/templates/delete.html
wget  ${FOLDER}/templates/add-update.html
cd ..
docker-compose up
