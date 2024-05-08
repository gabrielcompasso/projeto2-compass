#!/bin/bash

sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf

sudo yum update -y
sudo yum install docker -y 
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user

sudo yum install nfs-utils -y && sudo systemctl start nfs-utils && sudo systemctl enable nfs-utils

sudo mkdir /efs

sudo mount -t nfs4 -o nfsvers=4.1 fs-08a3a7ff4f3066d11.efs.us-east-1.amazonaws.com:/ efs
sudo echo "fs-08a3a7ff4f3066d11.efs.us-east-1.amazonaws.com:/ /efs nfs4 nfsvers=4.1 0 0" >> /etc/fstab

sudo mkdir /efs/wordpress

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Docker-compose.yaml
sudo cat <<EOL > /efs/docker-compose.yaml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: --------------.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: ------------
      WORDPRESS_DB_PASSWORD: ----------
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_TABLE_CONFIG: wp_
    volumes:
      - /efs/wordpress:/var/www/html
EOL

docker-compose -f /efs/docker-compose.yaml up -d