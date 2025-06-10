#!/bin/bash

################
# VALIDATE INPUT

if [ -z "$1" ]; then
  echo "Error: Go version not provided"
  echo "Usage: $0 <go_version> <kind_version> <pat>"
  exit 1
fi

GO_VERSION=$1

if [ -z "$2" ]; then
  echo "Error: Kind version not provided"
  echo "Usage: $0 <go_version> <kind_version> <pat>"
  exit 1
fi

KIND_VERSION=$2

##############
# BASIC SYSTEM

# Update all packages to the latest version
sudo apt-get update
sudo apt-get upgrade -y


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
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adding user to Docker group
sudo groupadd docker
sudo usermod -aG docker ${USER}

# Refresh group membership for current session
exec sg docker newgrp $(id -gn)


########
# GOLANG

# Download and install Go
curl -L "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
ln -s /usr/local/go/bin/go /usr/local/bin/go
ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Set environment variables
echo "export GOPATH=/go" >> /etc/profile.d/go.sh
echo "export PATH=\$GOPATH/bin:/usr/local/go/bin:\$PATH" >> /etc/profile.d/go.sh
chmod +x /etc/profile.d/go.sh

# Source the environment file for this session
source /etc/profile.d/go.sh

# Verify installation
go version

curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm /tmp/kubectl

# Verify installation
kubectl version --client


######
# KIND

go install sigs.k8s.io/kind@v${KIND_VERSION}

# Add kind to PATH
echo "export PATH=\$PATH:/home/${USER}/go/bin" >> /etc/profile.d/kind.sh
chmod +x /etc/profile.d/kind.sh

# Source the environment file for this session
source /etc/profile.d/kind.sh

# Verify installation
kind version


######
# HELM

curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
rm /tmp/get_helm.sh

# Verify installation
helm version
