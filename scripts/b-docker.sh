#!/usr/bin/env bash

######################################
# AUTOMATED DOCKER INSTALLATION SCRIPT

##############
# BASIC SYSTEM

# Update all packages to the latest version
sudo apt-get update


########
# DOCKER

# Setting up the repository
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Installing Docker
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adding user to Docker group
sudo groupadd docker || true
sudo usermod -aG docker ${USER} || true

# Refresh group membership for current session
exec su - ${USER}
